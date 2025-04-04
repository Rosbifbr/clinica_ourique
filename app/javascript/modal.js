document.addEventListener("DOMContentLoaded", function () {
  var deleteModal = document.getElementById("deleteModal");

  if (deleteModal) {
    deleteModal.addEventListener("show.bs.modal", function (event) {
      var button = event.relatedTarget; // Button that triggered the modal
      var itemName = button.getAttribute("data-item-name");
      var itemType = button.getAttribute("data-item-type");
      var itemUrl = button.getAttribute("data-item-url");

      console.log("Item Name:", itemName);
      console.log("Item Type:", itemType);
      console.log("Item URL:", itemUrl);

      document.getElementById("deleteItemName").textContent = itemName;
      document.getElementById("deleteItemType").textContent = itemType;
      document.getElementById("deleteForm").setAttribute("action", itemUrl);
    });
  }
});
