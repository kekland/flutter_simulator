extension Intersperse<T> on Iterable<T> {
  Iterable<T> intersperse(T element) sync* {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return;
    yield iterator.current;
    while (iterator.moveNext()) {
      yield element;
      yield iterator.current;
    }
  }
}

extension IntersperseList<T> on List<T> {
  List<T> intersperse(T element) {
    final result = <T>[];
    final iterator = this.iterator;
    if (!iterator.moveNext()) return result;
    result.add(iterator.current);
    while (iterator.moveNext()) {
      result.add(element);
      result.add(iterator.current);
    }
    return result;
  }
}
