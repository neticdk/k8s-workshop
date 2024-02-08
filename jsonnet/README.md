# Jsonnet Examples

[Jsonnet](https://jsonnet.org/) is a configuration language originating from Google. Jsonnet can be used to generate a number of different configuration formats but are specifically well tailored for [JSON](https://www.json.org/).

People from Grafana has defined the notion of a [Monitoring Mixin](https://github.com/monitoring-mixins/docs) which is a reusable component with Grafana dashboards and Prometheus recording and alerting rules. The mixins is written in Jsonnet.

These examples shows the usage of Jsonnet:

- [playground](./playground/) for live evaulation of Jsonnet scripts in a browser.
- [kubernetes-mixin](./kubernetes-mixin/) an example of using the [Prometheus Monotoring Mixin for Kubernetes](https://github.com/kubernetes-monitoring/kubernetes-mixin) to render Grafana dashboards
- [grafonnet](./grafonnet/) an example of using the Grafana [Grafonnet](https://github.com/grafana/grafonnet) library to build Grafana dashboards

_Note_: You may want to explore the [observability-helm](../observability-helm/) example to get a kind cluster running with Grafana and Prometheus.