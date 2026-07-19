abstract class AsyncValue<T> {
  const AsyncValue();

  const factory AsyncValue.data(T value) = AsyncData<T>;
  const factory AsyncValue.loading() = AsyncLoading<T>;
  const factory AsyncValue.error(Object error, [StackTrace? stackTrace]) = AsyncError<T>;

  R when<R>({
    required R Function(T data) data,
    required R Function(Object error, StackTrace? stackTrace) error,
    required R Function() loading,
  }) {
    if (this is AsyncData<T>) {
      return data((this as AsyncData<T>).value);
    } else if (this is AsyncError<T>) {
      final err = this as AsyncError<T>;
      return error(err.error, err.stackTrace);
    } else {
      return loading();
    }
  }
}

class AsyncData<T> extends AsyncValue<T> {
  final T value;
  const AsyncData(this.value);
}

class AsyncLoading<T> extends AsyncValue<T> {
  const AsyncLoading();
}

class AsyncError<T> extends AsyncValue<T> {
  final Object error;
  final StackTrace? stackTrace;
  const AsyncError(this.error, [this.stackTrace]);
}
