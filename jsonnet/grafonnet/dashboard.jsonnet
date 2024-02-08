local g = import 'g.libsonnet';

g.dashboard.new('CNCF Aalborg')
+ g.dashboard.withUid('cncf-aalborg-demo')
+ g.dashboard.withDescription('Dashboard for CNCF Aalborg demo')
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withPanels([
    g.panel.timeSeries.new('Requests / sec')
    + g.panel.timeSeries.queryOptions.withTargets([
        g.query.prometheus.new(
            'PBFA97CFB590B2093',
            'sum by (operation) (rate(etcd_request_duration_seconds_count[$__rate_interval]))',
        )
        + g.query.prometheus.withLegendFormat('{{ operation }}'),
    ])
    + g.panel.timeSeries.standardOptions.withUnit('reqps')
    + g.panel.timeSeries.gridPos.withW(24)
    + g.panel.timeSeries.gridPos.withH(8),
])
