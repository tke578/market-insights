document.addEventListener("turbolinks:load", () => {
  flatpickr(".datepicker", {
  	mode: "range",
    altInput: true,
    altFormat: "F j, Y",
    dateFormat: "m-d-Y"

  })
})

