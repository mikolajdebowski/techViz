abstract class RepositoryContract<T> {
  void onLoadData(List<T> result);
  void onLoadError(dynamic error);
}