bool isEmpty(String value) {
  return value.isEmpty ? false : true;
}

String checkEmpty(String value) {
  return !isEmpty(value) ? 'Vui lòng nhập' : null;
}