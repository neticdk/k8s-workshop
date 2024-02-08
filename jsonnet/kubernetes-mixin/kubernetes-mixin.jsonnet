local mixin = (import 'github.com/kubernetes-monitoring/kubernetes-mixin/mixin.libsonnet') + ({
  _config+:: {
    grafanaK8s: {
      dashboardNamePrefix: 'Netic OaaS / ',
      dashboardTags: ['netic-oaas','kubernetes-mixin'],
      linkPrefix: '',
      refresh: '10s',
      minimumTimeInterval: '1m',
      grafanaTimezone: 'browser',
    }
  },
});

mixin.grafanaDashboards
