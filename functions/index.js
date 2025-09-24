/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */


// Función para añadir el id y la fecha de creación a los usuarios de la colección contacts


const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const { FieldValue } = require("firebase-admin/firestore"); 

admin.initializeApp();

exports.newUser = onDocumentCreated("contacts/{userId}", async (event) => {
    const userId = event.params.userId;

    await admin.firestore().collection("contacts").doc(userId).update({
        id: userId,
        date: FieldValue.serverTimestamp()
    });

    console.log("Usuario", userId, " actualizado.");
});


// Función para obtener el texto de documentos y almacenarlo en firestore/processedFiles

const { onObjectFinalized } = require("firebase-functions/v2/storage");
const { Storage } = require("@google-cloud/storage");
const storage = new Storage();
const pdf = require("pdf-parse");

exports.processTextFile = onObjectFinalized(async (event) => {
    const filePath = event.data.name;
    const bucketName = event.data.bucket;

    if (!filePath.endsWith(".txt") && !filePath.endsWith(".pdf")) {
        console.log("Archivo no compatible, se ignora.");
        return;
    }

    const bucket = storage.bucket(bucketName);
    const file = bucket.file(filePath);

    const [content] = await file.download();

    let text = "";

    if (filePath.endsWith(".pdf")) {
        const pdfContent = await pdf(content);
        text = pdfContent.text;
    } else {
        text = content.toString("utf-8");
    }

    await admin.firestore().collection("processedFiles").add({
        fileName: filePath,
        content: text,
        date: FieldValue.serverTimestamp()
    });

    console.log("Archivo", filePath, " procesado y guardado en Firestore.");
});


