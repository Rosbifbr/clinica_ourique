document.addEventListener("DOMContentLoaded", function () {
  // Delete Modal Handler
  const deleteModal = document.getElementById("deleteModal");
  if (deleteModal) {
    deleteModal.addEventListener("show.bs.modal", function (event) {
      const button = event.relatedTarget;
      const itemName = button.getAttribute("data-item-name");
      const itemType = button.getAttribute("data-item-type");
      const itemUrl = button.getAttribute("data-item-url");

      document.getElementById("deleteItemName").textContent = itemName;
      document.getElementById("deleteItemType").textContent = itemType;
      document.getElementById("deleteForm").setAttribute("action", itemUrl);
    });
  }

  // Reset Modal Handler
  const resetModal = document.getElementById("resetModal");
  if (resetModal) {
    resetModal.addEventListener("show.bs.modal", function (event) {
      const button = event.relatedTarget;
      const itemName = button.getAttribute("data-item-name");
      const itemType = button.getAttribute("data-item-type");
      const itemUrl = button.getAttribute("data-item-url");

      document.getElementById("resetItemName").textContent = itemName;
      document.getElementById("resetItemType").textContent = itemType;
      document.getElementById("resetForm").setAttribute("action", itemUrl);
    });
  }

  // Full Image Modal Handler
  const fullImageModal = document.getElementById("fullImageModal");
  if (fullImageModal) {
    fullImageModal.addEventListener("show.bs.modal", function (event) {
      const button = event.relatedTarget;
      const imageUrl = button.getAttribute("data-bs-image-url");
      const imageName = button.getAttribute("data-bs-image-name");
      const imageId = button.getAttribute("data-bs-image-id");
      const clientId = button.getAttribute("data-bs-client-id");

      // Update modal title
      const modalTitle = document.getElementById("fullImageModalLabel");
      if (modalTitle) {
        modalTitle.textContent = imageName || "Image";
      }

      // Create a fresh image element for each modal display
      const container = document.getElementById("fullImageContainer");
      if (container && imageUrl) {
        container.innerHTML = ""; // Clear existing content
        const img = document.createElement("img");
        img.src = imageUrl;
        img.alt = imageName || "Image";
        img.className = "img-fluid rounded";
        img.style = "max-height: 600px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);";
        container.appendChild(img);
      }

      // Set up the delete button
      const deleteButton = document.getElementById("triggerDeleteModal");
      if (deleteButton && clientId && imageId) {
        // Use the correct route format based on your client#destroy_image route
        const deleteUrl = `/clients/${clientId}/images/${imageId}`;
        deleteButton.setAttribute("data-item-url", deleteUrl);
        deleteButton.setAttribute("data-item-name", imageName || "Image");
        deleteButton.setAttribute("data-item-type", "image");
      }
    });

    // Handle closing the full image modal when the delete button is clicked
    const triggerDeleteModal = document.getElementById("triggerDeleteModal");
    if (triggerDeleteModal) {
      triggerDeleteModal.addEventListener("click", function () {
        const modal = bootstrap.Modal.getInstance(fullImageModal);
        if (modal) {
          modal.hide();
        }
      });
    }
  }
});
