/**
 * Copyright 2016 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const logging = require('@google-cloud/logging')();
const stripe = require('stripe')(functions.config().stripe.token);
const currency = functions.config().stripe.currency || 'USD';
const succeeded = "succeeded"; 

// Charge the Stripe customer whenever an amount is written to the Realtime database
exports.createStripeCharge = functions.firestore.document('stripe_customers/{userId}/charges/{id}').onCreate(async (snap, context) => {
  const val = snap.data();
  try {
    // Look up the Stripe customer id written in createStripeCustomer
    const snapshot = await admin.firestore().collection(`stripe_customers`).doc(context.params.userId).get();
    const snapval = snapshot.data();
    const customer = snapval.customer_id;
    // Create a charge using the pushId as the idempotency key
    // protecting against double charges
    const amount = val.amount;
    const idempotencyKey = context.params.id;
    const charge = {amount, currency, customer};
    if (val.source !== null) {
      charge.source = val.source;
    }
    const response = await stripe.charges.create(charge, {idempotency_key: idempotencyKey});
    // If the result is successful, write it back to the database
    await snap.ref.set(response, { merge: true });
  } catch(error) {
    // We want to capture errors and render them in a user-friendly way, while
    // still logging an exception with StackDriver
    await snap.ref.set({error: userFacingMessage(error)}, { merge: true });
    return reportError(error, {user: context.params.userId});
  }
});

exports.createModerator = functions.https.onCall(async (data, context) => {
  if (context.auth.token.moderator !== true) {
    return {
      response: "Permission denied. User is not a moderator"
    }
  }
  const email = data.email;
  if (!email) {
    return {
      response: "please include user's email"
    };
  }
  const user = await admin.auth().getUserByEmail(email);
  if (!user) {
    return {
      response: `no user found for ${email}`
    };
  }
  const uid = user.uid;
  await admin.auth().setCustomUserClaims(uid, {moderator: true});
  return {
    response: `${email} is now a moderator`
  };
});

// When a user is created, register them with Stripe
exports.createStripeCustomer = functions.auth.user().onCreate(async (user) => {
  const customer = await stripe.customers.create({email: user.email});
  await admin.firestore().collection('stripe_customers').doc(user.uid).set({customer_id: customer.id});
});

exports.refundCharge = functions.firestore.document('refund_requests/{id}').onUpdate(async (change, context) => {
  // if user making a request is not a moderator, do not process
  // if (context.auth.token.moderator !== true) {
  //   console.log("refund could not be processed. User not a moderator");
  //   return Promise.resolve(null);
  // }
  const refund = change.after.data();
  const preRefund = change.before.data();

  // if the refund was already previously approved, 
  // then any changes made don't require an update
  if (preRefund.approvedAt || !refund.approvedAt) {
    console.log("refund could not be processed. Already previously approved or not approvedAt");
    return Promise.resolve(null);
  }
  // if the refund status didn't change,
  // no update required
  if (refund.approvedAt === preRefund.approvedAt) {
    console.log("refund could not be processed. Already previously approved");
    return Promise.resolve(null);
  }
  try {
    // wrap this in a try catch b/c what if this call fails due to stripe issues....
    const response = await stripe.refunds.create({charge: refund.id});
        if (response.status === succeeded) {
      await change.after.ref.set({refundedAt: Date.now(), response}, {merge: true});
    } else {
      await change.after.ref.set({attempedAt: Date.now(), response}, {merge: true});
    }
  } catch(error) {
    await change.after.ref.set({attempedAt: Date.now()}, {merge: true});
    return reportError(error, {user: context.params.userId});
  }
});

// Add a payment source (card) for a user by writing a stripe payment source token to Realtime database
exports.addPaymentSource = functions.firestore.document('/stripe_customers/{userId}/tokens/{pushId}').onWrite(async (change, context) => {
  const source = change.after.data();
  const token = source.token;
  if (source === null){
    return null;
  }

  try {
    const snapshot = await admin.firestore().collection('stripe_customers').doc(context.params.userId).get();
    const customer =  snapshot.data().customer_id;
    const response = await stripe.customers.createSource(customer, {source: token});
    await admin.firestore().collection('stripe_customers').doc(context.params.userId).collection("sources").doc(response.fingerprint).set(response, {merge: true});
  } catch (error) {
    await change.after.ref.set({'error':userFacingMessage(error)},{merge:true});
    return reportError(error, {user: context.params.userId});
  }
});

// When a user deletes their account, clean up after them
exports.cleanupUser = functions.auth.user().onDelete(async (user) => {
  const snapshot = await admin.database().ref(`/stripe_customers/${user.uid}`).once('value');
  const customer = snapshot.data();
  await stripe.customers.del(customer.customer_id);
  await admin.firestore().collection('stripe_customers').doc(user.uid).delete();
});

exports.chargeUpdate = functions.https.onRequest(async (req, res) => {
  const data = req.body.data;
  const customer = data.object.customer;
  const id = data.object.id;
  // get the Firebase user associated with the Stripe customer ID
  const snapshot = await admin.firestore().collection('stripe_customers').where('customer_id', '==', customer)
  .get();
  const customerDoc = snapshot.docs[0];
  const customerRef = customerDoc.ref;

  // get the document of the refunded charge
  const charge = await customerRef.collection('charges').where("id","==", id).get();
  const chargeDoc = charge.docs[0];

  // write the refund to the document
  await chargeDoc.ref.set(data.object,{merge: true});
  res.send("ok");
});

exports.chargeFailed = functions.https.onRequest(async (req, res) => {
  const data = req.body.data;
  const customer = data.object.customer;
  const id = data.object.id;
  // get the Firebase user associated with the Stripe customer ID
  const snapshot = await admin.firestore().collection('stripe_customers').where('customer_id', '==', customer)
  .get();
  const customerDoc = snapshot.docs[0];
  const customerRef = customerDoc.ref;

  // get the document of the refunded charge
  const charge = await customerRef.collection('charges').where("id","==", id).get();
  const chargeDoc = charge.docs[0];

  // write the refund to the document
  await chargeDoc.ref.set(data.object,{merge: true});
  res.send("ok");
});

exports.getUser = functions.https.onCall(async (data, context) => {
  const userId = data.userId;
  if (!userId) {
    return {
      email: "no userId provided"
    };
  }

  const user = await admin.auth().getUser(userId);
  const email = user.email;
  return {
    email
  };
});

// To keep on top of errors, we should raise a verbose error report with Stackdriver rather
// than simply relying on console.error. This will calculate users affected + send you email
// alerts, if you've opted into receiving them.
function reportError(err, context = {}) {
  // This is the name of the StackDriver log stream that will receive the log
  // entry. This name can be any valid log stream name, but must contain "err"
  // in order for the error to be picked up by StackDriver Error Reporting.
  const logName = 'errors';
  const log = logging.log(logName);

  // https://cloud.google.com/logging/docs/api/ref_v2beta1/rest/v2beta1/MonitoredResource
  const metadata = {
    resource: {
      type: 'cloud_function',
      labels: {function_name: process.env.FUNCTION_NAME},
    },
  };

  // https://cloud.google.com/error-reporting/reference/rest/v1beta1/ErrorEvent
  const errorEvent = {
    message: err.stack,
    serviceContext: {
      service: process.env.FUNCTION_NAME,
      resourceType: 'cloud_function',
    },
    context: context,
  };

  // Write the error log entry
  return new Promise((resolve, reject) => {
    log.write(log.entry(metadata, errorEvent), (error) => {
      if (error) {
       return reject(error);
      }
      return resolve();
    });
  });
}



// Sanitize the error message for the user
function userFacingMessage(error) {
  return error.type ? error.message : 'An error occurred, developers have been alerted';
}
