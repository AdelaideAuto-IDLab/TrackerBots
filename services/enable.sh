#!/bin/bash

systemctl daemon-reload

systemctl enable ioproxy.service
systemctl enable pulse_server.service
systemctl enable telemetry_host.service