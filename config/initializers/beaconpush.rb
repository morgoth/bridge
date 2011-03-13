# TODO: remove temporary fix for beaconpush gem

require "net/http"

Beaconpush.key = ENV["BRIDGE_BEACONPUSH_KEY"]
Beaconpush.secret = ENV["BRIDGE_BEACONPUSH_SECRET"]
