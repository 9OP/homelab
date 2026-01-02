# General

- The domain name is: `vestige-lab.xyz`, registrar: `namecheap.com`
- The authority DNS is cloudflare: `cloudflare.com`
- The public IP of the router is: `82.67.183.248`. (It should be hidden by cloudflare)
- The local hostname is: `vestige`
- Only HTTPS/443 should be port forward on the router
- Tailscale vestige IP: `100.125.13.105`, brainboard IP: `100.96.124.27`

## Namecheap steps:

Configure cloudflare as the authority name server.

Then forget about namecheap, this is only the registrar.

## Cloudflare steps:

- Set A / CNAME records
- Set security policy (eg. ban all IPs not from France, redirect http->https)
- Create certs for origin server and place in `../services/certs`

## Freebox router steps:

`http://mafreebox.freebox.fr`

- Find the IP of the raspberry (look at DHCP tab)
- Assign static DHCP "bail" - prevent IP rotation on reboot
- Create port forward on 443 to the raspberry

## Tailsclare steps:

`https://login.tailscale.com/admin/dns`

- create an entry in name-server and add `vestige.internal` with PI ip: `100.125.13.105`

## Rasbperry pi steps:

- install raspberrypi os using image manager
- connect to home router with ethernet
- proceed with SSH installation etc...
