"""django_test URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.urls import include, path
from rest_framework import routers
#qviews : quickstart 앱의 view, mviews : mask2face 앱의 view
from quickstart import views as qviews
from mask2face import views as mviews
from django.conf import settings
from django.conf.urls.static import static
from django.urls import include, path
from django.views.static import serve
from django.conf import settings
from django.conf.urls.static import static


router = routers.DefaultRouter()
router.register(r'users', qviews.UserViewSet)
router.register(r'groups', qviews.GroupViewSet)
router.register(r'PostContent', qviews.PostContentView, 'PostContent')
router.register(r'Post', mviews.PostViewSet, 'Post')

# Wire up our API using automatic URL routing.
# Additionally, we include login URLs for the browsable API.
urlpatterns = [
    path('', include(router.urls)),
    path('api-auth/', include('rest_framework.urls', namespace='rest_framework')),
    path('getoutput/', mviews.GetAPIView.as_view(), name = 'GetOutput'),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)