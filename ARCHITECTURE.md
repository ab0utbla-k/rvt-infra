# Infrastructure Architecture & Design Decisions

## Network Design

### Multi-AZ NAT Gateway Strategy

**Decision**: One NAT Gateway per Availability Zone (2 total)

* **Why**: Eliminates a single point of failure for outbound internet access
* **Trade-off**: Higher cost (\~\$30+/mo per NAT GW + data processing fees)
* **Alternative**: Single NAT Gateway to reduce cost, but introduces an availability risk — acceptable for dev/staging
* **Note**: This setup is standard for production-grade deployments prioritizing availability

---

### Three-Tier Subnet Architecture

**CIDR Allocation**:

* **Public**: 10.0.0.0/24, 10.0.1.0/24 (ALB, NAT Gateways)
* **App Tier**: 10.0.10.0/24, 10.0.11.0/24 (Application workloads)
* **DB Tier**: 10.0.20.0/24, 10.0.21.0/24 (Database instances)

**Why**: Implements a defense-in-depth approach

* Public subnets expose only essential internet-facing components
* App tier is isolated from the internet, reachable only via ALB
* DB tier has no route to the internet and is accessible only from the app tier

---

## Load Balancer Configuration

### Application Load Balancer vs Network Load Balancer

**Decision**: Use ALB for HTTP/HTTPS traffic

* **Why**: ALB provides Layer 7 routing (host/path-based), fine-grained health checks, and is more cost-effective for typical web applications
* **Trade-off**: Slightly higher latency than NLB, but much richer feature set for HTTP workloads
* **Alternative**: NLB is better for TCP or extreme performance needs

---

### Health Check Strategy

* **Path**: `/health` (application should expose this endpoint)
* **Thresholds**: Conservative fail thresholds to avoid flapping during load spikes
* **Consideration**: Tune health check intervals to avoid false alarms or missed failures

---

## Security Group Design

### Zero-Trust Tiered Access Pattern

* **ALB**

    * Inbound: ports 80/443 from the internet
    * Outbound: to app tier only

* **App Tier**

    * Inbound: from ALB security group only
    * Outbound: to DB tier only

* **DB Tier**

    * Inbound: from app tier only
    * No internet access by design

**Why**: Enforces least-privilege access between layers
**Note**: Pattern aligns with AWS Well-Architected Framework’s zero-trust principles

---

## Routing Architecture

### Per-AZ Route Tables

**Decision**: Use a separate route table for each AZ’s private subnets

* **Why**: Ensures traffic from private subnets uses NAT Gateway in the same AZ
* **Benefit**:

    * AZ-local routing improves performance
    * Avoids cross-AZ data transfer charges
* **Trade-off**: Slightly more verbose Terraform configuration
* **Alternative**: Shared route table is simpler but doesn’t support AZ-local egress routing

---
