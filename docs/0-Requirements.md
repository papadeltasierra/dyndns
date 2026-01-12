# Requirements
1. Provides a public-facing, reliable [DDNS] (Dynamic DNS) service to multiple customers
1. Uses standard [Azure] resources
1. Can be monetized via [Microsoft Marketplace] to cover costs
1. Provides a simple [Azure Portal] interface to allow [DDNS] domains to defined per-customer
    1. Optionally limits domains based on tiered pricing
    1. Version 0 limits to, say, 5 domains
1. Supports the standard [RFC 2136] [DDNS] updates method
1. Supports a non-standard [Azure] authentication based [DDNS] update method
1. Supports an [HTTPS] based update method if possible
1. Requires minimal maintenance
1. Uses standard [Azure] methods to ensure data (for example user); possible methods includes the folowing depending on the methodology chosen
    1. [Defining Durability for Memory-Optimized Objects]
    1. [Data redundancy - Azure Storage]
    1. [Reliability in Azure Blob Storage]


[DDNS]: https://en.wikipedia.org/wiki/Dynamic_DNS
[Azure Portal]: https://portal.azure.com
[Azure]: https://azure.microsoft.com/en-gb/pricing/purchase-options/azure-account/search?ef_id=_k_CjwKCAiA64LLBhBhEiwA-Pxgu6VfhF59ebKlCB6RJXiRgHKNIMkTyygfuh9cuycLPghwhdJQe270OhoCLeUQAvD_BwE_k_&OCID=AIDcmm3bvqzxp1_SEM__k_CjwKCAiA64LLBhBhEiwA-Pxgu6VfhF59ebKlCB6RJXiRgHKNIMkTyygfuh9cuycLPghwhdJQe270OhoCLeUQAvD_BwE_k_&gad_source=1&gad_campaignid=12265185555&gbraid=0AAAAADcJh_sekdQNc3aQ5cK_ea04maMNK&gclid=CjwKCAiA64LLBhBhEiwA-Pxgu6VfhF59ebKlCB6RJXiRgHKNIMkTyygfuh9cuycLPghwhdJQe270OhoCLeUQAvD_BwE
[Microsoft Marketplace]: https://marketplace.microsoft.com/en-us/
[RFC 2136]: https://www.rfc-editor.org/rfc/rfc2136.html
[HTTPS]: https://www.rfc-editor.org/rfc/rfc9110.html
[Defining Durability for Memory-Optimized Objects]: https://learn.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/defining-durability-for-memory-optimized-objects?view=sql-server-ver17
[Data redundancy - Azure Storage]: https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy
[Reliability in Azure Blob Storage]: https://learn.microsoft.com/en-us/azure/reliability/reliability-storage-blob
