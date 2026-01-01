# General

- The domain name is: `vestige-lab.xyz`, registrar: `namecheap.com`
- The authority DNS is cloudflare: `cloudflare.com`
- The public IP of the router is: `82.67.183.248`. (It should be hidden by cloudflare)
- The router port forward: `9222->22` to the raspberry
- The local hostname is: `vestige`

## Namecheap steps:

Configure cloudflare as the authority name server.

Then forget about namecheap, this is only the registrar.

## Cloudflare steps:

- Set A / CNAME records
- Set security policy (eg. ban all IPs not from France, redirect https->http)
- Create certs for origin server and place in /services/certs

## Freebox router steps:

`http://mafreebox.freebox.fr`

- Find the IP of the raspberry (look at DHCP tab)
- Assign static DHCP "bail" - prevent IP rotation on reboot
- Create port forward on 80/443 to the raspberry

## Rasbperry pi steps:

- install raspberrypi os using image manager
- connect to home router with ethernet
- proceed with SSH installation etc...
