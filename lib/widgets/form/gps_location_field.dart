import 'package:flutter/material.dart';

class GpsLocationField extends StatelessWidget {
  final bool isLoadingLocation;
  final String? gpsCity;
  final String locationError;
  final bool cityFoundByGPS;
  final VoidCallback onGetLocation;

  const GpsLocationField({
    Key? key,
    required this.isLoadingLocation,
    required this.gpsCity,
    required this.locationError,
    required this.cityFoundByGPS,
    required this.onGetLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mensaje informativo cuando la ciudad fue encontrada por GPS
          if (cityFoundByGPS && gpsCity != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .primaryColor
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context)
                      .primaryColor
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ubicación determinada automáticamente por GPS',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Icon(
                Icons.location_city,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Ciudad de inspección',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (isLoadingLocation)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  onPressed: onGetLocation,
                  icon: Icon(
                    Icons.my_location,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  tooltip: 'Obtener ubicación actual',
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (gpsCity != null)
            _buildCityDisplay(context, gpsCity!)
          else if (locationError.isNotEmpty)
            _buildErrorDisplay(context, locationError)
          else
            _buildPlaceholder(context),
        ],
      ),
    );
  }

  Widget _buildCityDisplay(BuildContext context, String city) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).primaryColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              city,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            Icons.lock,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_off,
            color: Theme.of(context).textTheme.bodyMedium?.color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Presiona el botón de ubicación para obtener la ciudad automáticamente',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
