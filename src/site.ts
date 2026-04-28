// Centralized event metadata. Update here, reflects everywhere.
export const site = {
  edition: "11th",
  year: 2026,
  title: "11th Summer School on Data and Algorithms for Science, Technology & Innovation Studies",
  shortTitle: "STI Summer School 2026",
  startDate: "2026-09-07",
  endDate: "2026-09-09",
  dateRange: "7–9 September 2026",
  city: "Nice",
  country: "France",
  venue: "Valrose Castle",
  venueAddress: "28 Avenue Valrose, 06100 Nice, France",
  fee: "€145",
  contactEmail: "sti@kuleuven.be",
  deadlines: {
    submission: { iso: "2026-05-08", label: "8 May 2026" },
    notification: { iso: "2026-05-22", label: "22 May 2026" },
    registration: { iso: "2026-08-15", label: "15 August 2026" },
  },
  partners: [
    { name: "KU Leuven", logo: "/images/logos/KULeuven.png" },
    { name: "SKEMA Business School", logo: "/images/logos/Skema.png" },
    { name: "Google", logo: "/images/logos/Google.png" },
    { name: "European Patent Office", logo: "/images/logos/EPO.png" },
    { name: "Université Côte d'Azur", logo: "/images/logos/University_CDA.jpg" },
    { name: "UCD Dublin", logo: "/images/logos/UCD.png" },
  ],
  // Cloudflare Worker URL that handles registration submissions and the
  // admin dashboard. Override at build time via PUBLIC_REGISTRATION_API.
  // Until set, the form shows a visible "not yet connected" warning.
  registrationApi: "https://your-worker.example.workers.dev",
  // Cloudflare Turnstile public site key for the registration form.
  // Override at build time via PUBLIC_TURNSTILE_SITE_KEY.
  turnstileSiteKey: "",
};

export function withBase(path: string): string {
  const base = import.meta.env.BASE_URL.replace(/\/$/, "");
  const clean = path.startsWith("/") ? path : `/${path}`;
  return `${base}${clean}`;
}
