Grafana Telegraf PowerShell Input Script for vCloud Director
===================================

# About

## Project Owner:

Markus Kraus [@vMarkus_K](https://twitter.com/vMarkus_K)

MY CLOUD-(R)EVOLUTION [mycloudrevolution.com](http://mycloudrevolution.com/)

## Project WebSite

MY CLOUD-(R)EVOLUTION [mycloudrevolution.com](http://mycloudrevolution.com/)

## Project Details

This Repository contains a PowerShell Input Script for Telegraf to collect vCloud Director stats. The generated Data will be used for my [Grafa Dashboard](https://grafana.com/dashboards/5081).

# Installation

## Telegraf

Snippet of the telegraf.conf input:

``
[[inputs.exec]]
  commands = ["pwsh /scripts/Grafana-Telegraf-vCloud-PsCore/vCloud.ps1"]
  name_override = "vCloudStats"
  interval = "60s"
  timeout = "60s"
  data_format = "influx"
``

## Grafana

Just Import my [Grafa Dashboard](https://grafana.com/dashboards/5081).

# Screenshots

![Dashboard - Summary](/media/Dashboard-Summary.png)

![Dashboard - vApp](/media/Dashboard-vApp.png)

![Dashboard - OrgVdc](/media/Dashboard-OrgVdc.png)


![Dashboard - Net and Edge](/media/Dashboard-NetAndEdge.png)