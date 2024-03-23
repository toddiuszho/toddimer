  // contentscript.js
  (function() {
    // Hide the Care reaction button
    const careReactionButton = document.querySelector("[aria-label='Care']");
    if (careReactionButton) {
      careReactionButton.style.display = "none";
    }
  
    // Block notifications about Care reactions
    const observer = new MutationObserver(function(mutations) {
      for (const mutation of mutations) {
        if (mutation.type === "childList") {
          const notificationList = mutation.target.querySelector("[aria-label='Notifications']");
          if (notificationList) {
            for (const notification of notificationList.children) {
              if (notification.textContent.includes("Care")) {
                notification.style.display = "none";
              }
            }
          }
        }
      }
    });
  
    observer.observe(document.body, {
      childList: true
    });
  })();
