""" Utility functions related to HTTP requests """
from django.conf import settings
from microsite_configuration.middleware import MicrositeConfiguration
from django.contrib.gis.geoip import GeoIP
from functools import wraps
from django.shortcuts import redirect


def safe_get_host(request):
    """
    Get the host name for this request, as safely as possible.

    If ALLOWED_HOSTS is properly set, this calls request.get_host;
    otherwise, this returns whatever settings.SITE_NAME is set to.

    This ensures we will never accept an untrusted value of get_host()
    """
    if isinstance(settings.ALLOWED_HOSTS, (list, tuple)) and '*' not in settings.ALLOWED_HOSTS:
        return request.get_host()
    else:
        return MicrositeConfiguration.get_microsite_configuration_value('site_domain', settings.SITE_NAME)

def embargo_check(func):
    def _wrapped_view(request, *args, **kwargs):
        ip = request.META['HTTP_X_FORWARDED_FOR']
        geoip = GeoIp()
        if geoip.country_code(ip) in EmbargoConfig.embargoed_countries_list():
            return redirect('embargo')
        return func(request, *args, **kwargs)
    return _wrapped_view

"""
def embargo_check(func):
    """ """
    Decorator that redirects the user to an "embargo information" page
    iff (1) that course is embargoed, and (2) the user is accessing the
    site from an embargoed IP.
    """ """
    @wraps(func)
    def dispatch_wrapper(self, request, *args, **kwargs):
        if course_id in EmbargoConfig.embargoed_courses_list():
            ip = request.META['HTTP_X_FORWARDED_FOR']
            geoip = GeoIp()
            if geoip.country_code(ip) in EmbargoConfig.embargoed_countries_list():
                return redirect('embargo')
            return func(self, request, *args, **kwargs)
        return dispatch_wrad
"""