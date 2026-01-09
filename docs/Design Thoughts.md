# Design Thoughts
1. User _buys_ access to the product via [Microsoft Marketplace]
    1. System must support sign-up, sign-out/expiry
1. Customer accesses the system via an [Azure Portal] page
1. A Microsoft database ([Azure Cosmos DB]?) stores the user identity and the [DDNS] (Dynamic DNS) sub-domains that they want supported
1. A [DDNS Update] can update an existing domain entry in the database
1. An Azure-tool based [DDNS] update can update an existing entry in the database
1. An [HTTPS] based update can update an exsting entry in the database
1. An [HTTPS]
1. A database background task runs ever 10 minues or so and does the following:
    1. _**Consider whether throttling is required and if so, how**_
    1. Lists all database changes that occurred since the last access (perhaps allowing for some overlap of time)
    1. Removes any [DDNS] sub-domains now flagged as deleted and then deletes the database entry as well
    1. Adds any new [DDNS] sub-domains created
    1. Updates any [DDNS] sub-domains where the IP address has changed

## Portal Design
- Provides `Add` and `Delete` [DDNS] sub-domain commands but no update
- Lists existing sub-domains and for each shows
  - The [DDNS] sub-domain name
  - The time that the [DDNS] sub-domain was registered
  - The last registered IPv4 address
  - The last registered IPv6 address
  - The last time the IPv4 address was confirmed
  - The last time the IPv6 address was confirmed

## Database Design
Entries:
- Are indexed on [Azure] account name and [DDNS] sub-domain
- Contains the [Azure] account identifier
- Contains the [DDNS] sub-domain
- Contains the optional IPv4 address registered
- Contains the optional IPv6 address registered
- Contains the time that the entry was created/registered
- Contains two times, the last time each address was updated

## Azure [DDNS] Update tool
- Assumes `az login` has occurred
- Connects to the tool that backs the portal using an [HTTPS] REST API
    - This implies there is always an [HTTPS] API but does this mean we need some way to provide a long-lived session key?
    - If so, who manages this?
- Updates the IPv4 and/or IPv6 addresses

> Question: How is/are the correct IPv4/IPv6 address(es) to register determined?


[Microsoft Marketplace]: https://marketplace.microsoft.com/en-us/
[Azure Portal]: https://portal.azure.com
[Azure Cosmos DB]: https://azure.microsoft.com/en-us/products/cosmos-db
[DDNS]: https://en.wikipedia.org/wiki/Dynamic_DNS
[DDNS Update]: https://datatracker.ietf.org/doc/html/rfc2136
[Azure]: https://azure.microsoft.com/en-gb/pricing/purchase-options/azure-account/search?ef_id=_k_CjwKCAiA64LLBhBhEiwA-Pxgu6VfhF59ebKlCB6RJXiRgHKNIMkTyygfuh9cuycLPghwhdJQe270OhoCLeUQAvD_BwE_k_&OCID=AIDcmm3bvqzxp1_SEM__k_CjwKCAiA64LLBhBhEiwA-Pxgu6VfhF59ebKlCB6RJXiRgHKNIMkTyygfuh9cuycLPghwhdJQe270OhoCLeUQAvD_BwE_k_&gad_source=1&gad_campaignid=12265185555&gbraid=0AAAAADcJh_sekdQNc3aQ5cK_ea04maMNK&gclid=CjwKCAiA64LLBhBhEiwA-Pxgu6VfhF59ebKlCB6RJXiRgHKNIMkTyygfuh9cuycLPghwhdJQe270OhoCLeUQAvD_BwE
[HTTPS]: https://www.rfc-editor.org/rfc/rfc9110.html