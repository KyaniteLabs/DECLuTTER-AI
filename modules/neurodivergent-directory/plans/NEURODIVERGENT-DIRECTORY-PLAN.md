# NeuroDivergent Directory — Business Plan

**Created:** 2026-02-22  
**Owner:** Simon  
**Research:** Teo

---

## Executive Summary

A niche directory connecting late-diagnosed neurodivergent BIPOC adults with culturally online competent professionals, resources, tools, and communities.

**The Problem:** BIPOC adults are underdiagnosed, misdiagnosed, and face a critical lack of culturally affirming care. Existing directories don't filter by BIPOC-affirming providers or focus on the late-diagnosis experience.

**The Solution:** A searchable directory with real verification — providers, coaches, employers, products, and communities — curated by and for late-diagnosed BIPOC NDs.

**Target:** Late-diagnosed ADHD/AuDHD/autistic BIPOC adults (ages 18-45)

**Revenue Model:** Provider listings ($49-149/mo) + affiliate commissions + premium membership

---

## Market Opportunity

### The Gap

| Existing Directories | What They Lack |
|---------------------|----------------|
| Neurodiversity.directory | BIPOC filtering, late-diagnosis focus |
| Neurodirect.co.uk | US market, cultural competency verification |
| Provider directories | Real reviews from BIPOC users |
| General ADHD sites | Intersectional focus |

### Market Size (US)

- **ADHD in adults:** ~4.4% prevalence → ~11M adults
- **Autism in adults:** ~1-2% → ~2.5-5M adults  
- **BIPOC share:** ~40% of US population → potentially 5-6M BIPOC ND adults
- **Late-diagnosed:** Growing wave, especially ages 25-40

### Why Now

1. Late-diagnosis trend accelerating (TikTok, social media awareness)
2. BIPOC communities demanding culturally competent care
3. Employer diversity pushes for ND-inclusive hiring
4. No direct competitor in this niche intersection

---

## Value Proposition

**For Users (Free):**
- Find verified BIPOC-affirming therapists/assessors
- Discover ND-friendly employers
- Get post-diagnosis guidance (practical, not clinical)
- Connect with community

**For Providers ($49-149/mo):**
- Verified "BIPOC-affirming" badge
- Profile with specialization tags
- Lead capture from directory
- Community access

**Moat:** Real verification process + user reviews from BIPOC NDs

---

## Features

### MVP (Phase 1)

1. **Provider Directory**
   - Search by: Location, specialty, insurance, language, identity
   - Filter: "BIPOC-affirming verified"
   - Profile: Bio, specialties, credentials, contact

2. **Basic Listings**
   - Tools & apps (affiliate)
   - Products (sensory, ADHD tools)
   - Community resources (Discord, meetups)

3. **Reviews & Verification**
   - User-submitted reviews (must verify identity)
   - Provider verification process (application + review)

### Phase 2

4. **Job Board**
   - ND-friendly employers
   - Filter by remote/hybrid/onsite

5. **Post-Diagnosis Guides**
   - Practical content (not clinical)
   - Written by late-diagnosed BIPOC

6. **Premium Membership**
   - Early access to providers
   - Community discord access
   - Exclusive content

### Phase 3

7. **Multi-language support**
8. **Provider claiming & self-service**
9. **Events calendar**

---

## Tech Stack

### Option A: WordPress + Directory Plugin (Recommended for MVP)

| Component | Choice | Cost |
|-----------|--------|------|
| Hosting | Cloudways (WP-optimized) | $25-40/mo |
| CMS | WordPress | Free |
| Directory | GeoDirectory or ListPress | $99-199 (one-time) |
| Theme | Crocoblock or custom | Included |
| Domain | .com (via Namecheap) | $12/yr |

**Pros:** Fastest to launch, familiar to Simon, easy updates  
**Cons:** Can get bloaty, less custom  

**Timeline:** 2-3 weeks

### Option B: Static Site + CMS (Astro + Sanity)

| Component | Choice | Cost |
|-----------|--------|------|
| Hosting | Vercel | Free tier |
| Frontend | Astro | Free |
| CMS | Sanity | Free tier (10k docs) |
| Directory | Custom | Dev time |

**Pros:** Fast, modern, less maintenance  
**Cons:** More dev time  

**Timeline:** 4-6 weeks

### Option C: No-Code (Framer + Softr)

| Component | Choice | Cost |
|-----------|--------|------|
| Site | Framer | $20/mo |
| Directory | Softr + Airtable | $49/mo |

**Pros:** Fastest, no code  
**Cons:** Less control, ongoing costs  

**Timeline:** 1-2 weeks

### Recommendation

**Start with Option A (WordPress + GeoDirectory)** for:
- Fastest launch
- Built-in directory features (search, filters, profiles)
- Easy for Simon to manage
- Can migrate later if needed

---

## GeoDirectory Verification Capability Assessment

**Assessment Date:** 2026-02-22  
**Researcher:** Teo

### Verified: GeoDirectory CAN Handle BIPOC-Affirming Verification

| Feature | Status | Notes |
|---------|--------|-------|
| **Custom fields** | ✅ YES | Can add custom fields for verification badges, identity categories, languages spoken |
| **Conditional fields** | ✅ YES | Show/hide fields based on category selection |
| **Pending approval** | ✅ YES | New listings can go to "pending" status for admin review |
| **Claim Listings add-on** | ✅ YES | Allows provider verification, verified badges, email verification |
| **User reviews** | ✅ YES | Built-in review system |
| **Filtering** | ✅ YES | Can filter by custom field values (e.g., "BIPOC-affirming verified") |

### Proposed Verification Workflow

1. **Provider submits listing** → Custom field: "BIPOC-affirming certification"
2. **Admin review** → Listings set to "pending" by default
3. **Verification check** → Manual review of credentials, self-attestation
4. **Approved** → Badge displayed, listing goes live
5. **User reviews** → Additional verification signal from BIPOC ND users

### Add-ons Required

- **Claim Listings** ($99 one-time) — Verification badges, claimed profiles
- **Pricing Manager** (if monetizing) — Package tiers
- **Multi-location** (if needed) — Multiple regions

### Verdict: ✅ PROCEED WITH GEODIRECTORY

---

## Monetization

### Revenue Streams

| Stream | Potential | Timeline |
|--------|-----------|----------|
| **Featured provider listings** | $2,000-5,000/mo (40-80 providers) | Month 3+ |
| **Affiliate (tools/apps)** | $500-2,000/mo | Month 1+ |
| **Premium membership** | $9-29/mo × 200 members | Month 6+ |
| **Job board listings** | $200-500/mo | Month 4+ |
| **Ad space** | $200-500/mo | Month 6+ |

### Pricing Tiers (Providers)

| Tier | Price | Features |
|------|-------|----------|
| **Basic** | Free | Basic listing, no verification |
| **Verified** | $49/mo | Badge, full profile, contact form |
| **Premium** | $149/mo | Top of search, featured, analytics |

### Year 1 Projection (Conservative)

- Month 1-3: $0 (build)
- Month 4-6: $1,000-2,000/mo
- Month 7-12: $3,000-5,000/mo

---

## Launch Strategy

### Pre-Launch (Weeks 1-2)

1. **Niche down:** Finalize name + branding
2. **Content first:** Launch blog (post-diagnosis guides, "what to expect")
3. **Build email list:** Lead magnet (free ND resource guide)
4. **Social presence:** TikTok, Instagram (shareable content)

### Soft Launch (Week 3)

1. **Provider outreach:** 20-30 free listings (invite-only)
2. **User testing:** Feedback from 5-10 late-diagnosed BIPOC
3. **Iterate:** Fix issues

### Official Launch (Week 4)

1. **Announce:** Twitter/X, TikTok, neurodivergent communities
2. **Press:** 1-2 guest posts on ND blogs
3. **Affiliate:** Sign up for ADHD app affiliates

### Growth (Months 2-6)

1. **Provider paid tiers:** Convert free to paid
2. **SEO:** Target "BIPOC ADHD therapist [city]" keywords
3. **Community:** Discord server, email newsletter
4. **Content:** More guides, provider spotlights

---

## Timeline

| Phase | Duration | Deliverables |
|-------|----------|--------------|
| **Phase 1: Research & Planning** | 1 week | Finalize niche, name, branding |
| **Phase 2: Build** | 2-3 weeks | WP setup, directory, 20 providers |
| **Phase 3: Soft Launch** | 1 week | Testing, feedback, fixes |
| **Phase 4: Launch** | Ongoing | Marketing, content, growth |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Provider verification is hard** | High | Medium | Partner with existing orgs (NeuroClastic); user reviews as primary signal |
| **Low provider willingness to pay** | Medium | High | Start free, prove ROI with leads generated |
| **Community trust** | High | High | Be BIPOC-led; transparent about verification; no "rainbow washing" |
| **SEO competition** | Medium | Medium | Long-tail keywords; niche focus |
| **Content overload** | Medium | Low | Start minimal; add based on demand |

---

## Next Steps

1. **Simon approves plan** ✅ (in progress)
2. **Kai reviews:** Tech stack feasibility, build effort estimate
3. **Liam reviews:** Business logic, timeline, prioritization
4. **Finalize:** Name, branding, domain
5. **Build:** WP installation, GeoDirectory setup
6. **Content:** First 10 post-diagnosis guides

---

## Discussion Questions for Kai & Liam

### For Kai (Technical)
- WordPress + GeoDirectory viable for MVP?
- Any concerns with hosting/scaling?
- Estimated build time?

### For Liam (Business/Coordination)
- Timeline realistic?
- Revenue projections reasonable?
- Any missing features for launch?
- How does this fit with broader system (agents working on this)?

---

*Plan prepared by Teo. Ready for review.*
