const admin = require("firebase-admin");

let serviceAccount = null;

if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  try {
    serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
  } catch (error) {
    throw new Error("Invalid FIREBASE_SERVICE_ACCOUNT JSON");
  }
}

if (!serviceAccount) {
  serviceAccount = require("./finder-app-14ea2-7a111cd02cc5.json");
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

module.exports = admin;
