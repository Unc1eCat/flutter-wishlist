extension ListUtilExtension<T> on List<T> {
  T replaceFirstWhere(bool Function(T e) test, T newValue) {
    var index = indexWhere((e) => test(e));
    var oldValue = this[index];
    this[index] = newValue;
    return oldValue;
  }
}