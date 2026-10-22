// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
    apiKey: "AIzaSyAZ8iLBWHA9cEwqF_td6ZgHMmnp1oiSV78",
    authDomain: "breathtrack-e418b.firebaseapp.com",
    projectId: "breathtrack-e418b",
    storageBucket: "breathtrack-e418b.firebasestorage.app",
    messagingSenderId: "830813254082",
    appId: "1:830813254082:web:9c852fc273cdfc9eb2265b",
    measurementId: "G-G9WBT2R9S5"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = typeof window !== "undefined" ? getAnalytics(app) : null;

export { app, analytics };
