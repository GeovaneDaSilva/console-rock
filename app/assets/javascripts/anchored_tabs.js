if (window.location.hash.length > 0) {
  var link = document.querySelector("[href=\"".concat(window.location.hash, "\"]"));

  if (link != undefined) {
    link.click();
  }
}
