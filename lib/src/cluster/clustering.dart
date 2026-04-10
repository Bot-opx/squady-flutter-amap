import 'dart:math' as math;

import 'package:amap_flutter_base_plus/amap_flutter_base_plus.dart';

typedef AMapClusterPositionResolver<T> = LatLng Function(T item);

/// Controls how markers are grouped into clusters in Dart space.
class AMapClusterOptions {
  const AMapClusterOptions({
    this.enableClustering = true,
    this.gridSizePx = 96.0,
    this.disableClusteringZoom = 15.5,
    this.minClusterSize = 2,
    this.minZoom,
    this.maxZoom,
  }) : assert(gridSizePx > 0),
       assert(minClusterSize > 0);

  final bool enableClustering;
  final double gridSizePx;
  final double disableClusteringZoom;
  final int minClusterSize;
  final double? minZoom;
  final double? maxZoom;

  bool shouldClusterAtZoom(double zoom) {
    if (!enableClustering) return false;
    if (zoom >= disableClusteringZoom) return false;
    if (minZoom != null && zoom < minZoom!) return false;
    if (maxZoom != null && zoom > maxZoom!) return false;
    return true;
  }

  AMapClusterOptions copyWith({
    bool? enableClustering,
    double? gridSizePx,
    double? disableClusteringZoom,
    int? minClusterSize,
    double? minZoom,
    double? maxZoom,
  }) {
    return AMapClusterOptions(
      enableClustering: enableClustering ?? this.enableClustering,
      gridSizePx: gridSizePx ?? this.gridSizePx,
      disableClusteringZoom:
          disableClusteringZoom ?? this.disableClusteringZoom,
      minClusterSize: minClusterSize ?? this.minClusterSize,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
    );
  }
}

/// A group of items produced by [buildAMapClusters].
class AMapCluster<T> {
  AMapCluster({
    required this.items,
    required this.center,
    required this.cellKey,
    required this.isCluster,
  });

  final List<T> items;
  final LatLng center;
  final String cellKey;
  final bool isCluster;

  int get count => items.length;

  T get first => items.first;
}

List<AMapCluster<T>> buildAMapClusters<T>({
  required Iterable<T> items,
  required double zoom,
  required AMapClusterPositionResolver<T> positionOf,
  AMapClusterOptions options = const AMapClusterOptions(),
}) {
  if (!options.shouldClusterAtZoom(zoom)) {
    return items
        .map((item) {
          final LatLng position = positionOf(item);
          return AMapCluster<T>(
            items: <T>[item],
            center: position,
            cellKey: '${position.latitude}:${position.longitude}',
            isCluster: false,
          );
        })
        .toList(growable: false);
  }

  final Map<String, _AMapClusterBucket<T>> buckets =
      <String, _AMapClusterBucket<T>>{};

  for (final T item in items) {
    final LatLng position = positionOf(item);
    final _WorldPixel pixel = _toWorldPixel(
      lat: position.latitude,
      lng: position.longitude,
      zoom: zoom,
    );
    final int gridX = (pixel.x / options.gridSizePx).floor();
    final int gridY = (pixel.y / options.gridSizePx).floor();
    final String key = '$gridX:$gridY';
    final _AMapClusterBucket<T> bucket = buckets.putIfAbsent(
      key,
      () => _AMapClusterBucket<T>(),
    );
    bucket.add(item, position);
  }

  return buckets.entries.map((entry) {
    final _AMapClusterBucket<T> bucket = entry.value;
    final bool isCluster = bucket.count >= options.minClusterSize;
    if (!isCluster) {
      final T item = bucket.items.first;
      final LatLng position = bucket.positions.first;
      return AMapCluster<T>(
        items: <T>[item],
        center: position,
        cellKey: entry.key,
        isCluster: false,
      );
    }
    return AMapCluster<T>(
      items: List<T>.unmodifiable(bucket.items),
      center: bucket.center,
      cellKey: entry.key,
      isCluster: true,
    );
  }).toList(growable: false);
}

class _AMapClusterBucket<T> {
  final List<T> items = <T>[];
  final List<LatLng> positions = <LatLng>[];
  double _latSum = 0;
  double _lngSum = 0;

  int get count => items.length;

  LatLng get center => LatLng(_latSum / count, _lngSum / count);

  void add(T item, LatLng position) {
    items.add(item);
    positions.add(position);
    _latSum += position.latitude;
    _lngSum += position.longitude;
  }
}

_WorldPixel _toWorldPixel({
  required double lat,
  required double lng,
  required double zoom,
}) {
  final double clampedLat = lat.clamp(-85.05112878, 85.05112878).toDouble();
  final double siny = math.sin(clampedLat * math.pi / 180.0);
  final double scale = 256.0 * math.pow(2.0, zoom).toDouble();
  final double x = (lng + 180.0) / 360.0 * scale;
  final double y =
      (0.5 - math.log((1 + siny) / (1 - siny)) / (4 * math.pi)) * scale;
  return _WorldPixel(x: x, y: y);
}

class _WorldPixel {
  const _WorldPixel({
    required this.x,
    required this.y,
  });

  final double x;
  final double y;
}
