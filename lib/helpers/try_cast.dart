T? tryCast<T>(dynamic value, {T? fallback}) {
  try {
    return (value as T);
  } on TypeError catch (_) {
    return fallback;
  }
}
