const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { Firestore } = require('@google-cloud/firestore');

const app = express();
app.use(cors());
app.use(bodyParser.json());

const firestore = new Firestore();
const menuCollection = firestore.collection('menus');

// Get all menu items
app.get('/menus', async (req, res) => {
  try {
    const snapshot = await menuCollection.get();
    const menus = [];
    snapshot.forEach(doc => menus.push({ id: doc.id, ...doc.data() }));
    res.json(menus);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Create a menu item
app.post('/menus', async (req, res) => {
  try {
    const docRef = await menuCollection.add(req.body);
    const doc = await docRef.get();
    res.status(201).json({ id: doc.id, ...doc.data() });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Update a menu item
app.put('/menus/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await menuCollection.doc(id).set(req.body, { merge: true });
    const doc = await menuCollection.doc(id).get();
    res.json({ id: doc.id, ...doc.data() });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Delete a menu item
app.delete('/menus/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await menuCollection.doc(id).delete();
    res.status(204).send();
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Menu API listening on port ${PORT}`));
