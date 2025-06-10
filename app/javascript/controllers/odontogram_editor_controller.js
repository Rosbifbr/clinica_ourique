import { Controller } from "@hotwired/stimulus"
import { fabric } from "fabric" // Import fabric from the import map

// Connects to data-controller="odontogram-editor"
export default class extends Controller {
  static targets = [ "canvas", "canvasJsonOutput" ] // Added canvasJsonOutput target
  static values = { initialCanvasJson: String } // To pass existing JSON data

  // Define the default odontogram state (Fabric.js JSON format)
  // This is a very simple example: a background color and a piece of text.
  // A real default odontogram would have many more objects (teeth outlines, etc.)
  DEFAULT_ODONTOGRAM_JSON = {
    "version": "5.3.0", // Match Fabric.js version if possible
    "objects": [
      {
        "type": "rect",
        "version": "5.3.0",
        "originX": "left",
        "originY": "top",
        "left": 0,
        "top": 0,
        "width": 500,
        "height": 300,
        "fill": "#f0f0f0", // Light grey background for the default
        "selectable": false,
        "evented": false,
      },
      {
        "type": "i-text",
        "version": "5.3.0",
        "originX": "center",
        "originY": "center",
        "left": 250,
        "top": 50,
        "text": "Default Odontogram",
        "fontSize": 24,
        "fill": "grey",
        "selectable": false,
      },
      // Example of a tooth placeholder (simple circle)
      {
        "type": "circle",
        "version": "5.3.0",
        "originX": "center",
        "originY": "center",
        "left": 100,
        "top": 150,
        "radius": 20,
        "fill": "white",
        "stroke": "black",
        "strokeWidth": 1,
        "selectable": true, // Make teeth selectable/editable
        "data": { "toothId": "11" } // Custom data attribute
      },
      {
        "type": "circle",
        "version": "5.3.0",
        "originX": "center",
        "originY": "center",
        "left": 150,
        "top": 150,
        "radius": 20,
        "fill": "white",
        "stroke": "black",
        "strokeWidth": 1,
        "selectable": true,
        "data": { "toothId": "12" }
      }
      // ... more objects for a full default odontogram
    ]
  };

  connect() {
    console.log("Odontogram Editor Controller connected!");
    this.initializeCanvas();

    // Debug: Add a test shape to see if canvas is working
    // setTimeout(() => this.addTestShape(), 1000);
  }

  disconnect() {
    if (this.canvasInstance) {
      this.canvasInstance.dispose();
      this.canvasInstance = null; // Ensure it's cleared
      console.log("Fabric.js canvas disposed.");
    }
  }

  initializeCanvas() {
    if (this.hasCanvasTarget) {
      if (this.canvasInstance) { // Prevent re-initialization if already exists
          this.canvasInstance.clear(); // Clear previous content
          this.canvasInstance.dispose(); // Dispose old instance fully
          this.canvasInstance = null;
      }

      this.canvasInstance = new fabric.Canvas(this.canvasTarget, {
        width: this.canvasTarget.offsetWidth || 500, // Use actual width or default
        height: 300, // Default height, can be dynamic
        backgroundColor: 'white', // Base background, might be overridden by loaded JSON
      });
      console.log("Fabric.js canvas initialized on target:", this.canvasTarget);

      this.loadInitialData();

      // Listen to canvas modifications to update the hidden output field
      this.canvasInstance.on('object:modified', this.updateJsonOutput.bind(this));
      this.canvasInstance.on('object:added', this.updateJsonOutput.bind(this));
      this.canvasInstance.on('object:removed', this.updateJsonOutput.bind(this));

    } else {
      console.error("Odontogram editor is missing canvas target.");
    }
  }

  loadInitialData() {
    // If initialCanvasJsonValue is provided (e.g., from server-side model), load it.
    // Otherwise, load the default odontogram.
    if (this.hasInitialCanvasJsonValue && this.initialCanvasJsonValue.length > 0 && this.initialCanvasJsonValue !== "null") {
      try {
        const jsonData = JSON.parse(this.initialCanvasJsonValue);
        this.loadCanvasDataJSON(jsonData);
        console.log("Loaded existing odontogram data.");
      } catch (e) {
        console.error("Error parsing initialCanvasJsonValue:", e);
        this.loadDefaultOdontogram();
      }
    } else {
      this.loadDefaultOdontogram();
      console.log("Loaded default odontogram data.");
    }
    this.updateJsonOutput(); // Update output after loading
  }

  loadDefaultOdontogram() {
    this.loadCanvasDataJSON(this.DEFAULT_ODONTOGRAM_JSON);
  }

  getCanvasDataJSON() {
    if (this.canvasInstance) {
      return JSON.stringify(this.canvasInstance.toJSON(['data'])); // Include custom 'data' attributes
    }
    return null;
  }

  loadCanvasDataJSON(jsonData) {
    if (this.canvasInstance && jsonData) {
      this.canvasInstance.loadFromJSON(jsonData, () => {
        this.canvasInstance.renderAll();
        console.log("Canvas data loaded/rendered.");
      });
    }
  }

  updateJsonOutput() {
    if (this.hasCanvasJsonOutputTarget) {
      const jsonData = this.getCanvasDataJSON();
      if (jsonData) {
        this.canvasJsonOutputTarget.value = jsonData;
        // Dispatch an event so other parts of the form can react if needed
        this.canvasJsonOutputTarget.dispatchEvent(new Event('change', { bubbles: true }));
      }
    }
  }

  // Called by a "Restore to Default" button
  restoreDefault() {
    if (confirm("Are you sure you want to restore the odontogram to its default state? Any unsaved changes will be lost from the editor.")) {
      this.loadDefaultOdontogram();
      this.updateJsonOutput(); // Ensure the hidden field is updated for form submission
    }
  }

  // Example: Add a simple shape (for testing, can be removed later)
  addTestShape() {
    if (this.canvasInstance) {
      const rect = new fabric.Rect({
        left: Math.random() * 400,
        top: Math.random() * 250,
        fill: 'blue',
        width: 30,
        height: 30,
        angle: Math.random() * 90
      });
      this.canvasInstance.add(rect);
      this.updateJsonOutput(); // Update after adding shape
    }
  }
}
