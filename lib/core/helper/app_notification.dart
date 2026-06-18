String getNotificationTitle(String status) {
  switch (status) {
    case "process":
      return "Pesanan sedang diproses";
    case "selesai":
      return "Pesanan siap diambil";
    default:
      return "";
  }
}

String getNotificationMessage(String status) {
  switch (status) {
    case "process":
      return "Admin sedang menyiapkan pesananmu.";
    case "selesai":
      return "Pesananmu sudah selesai dan siap diambil.";
    default:
      return "";
  }
}