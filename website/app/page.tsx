import Image from "next/image";
import Link from "next/link";

export default function Home() {
  return (
    <div className="min-h-screen bg-background text-foreground">
      {/* Hero Section */}
      <section className="relative h-screen flex items-center justify-center px-4 sm:px-6 lg:px-8 overflow-hidden">
        <video
          autoPlay
          loop
          muted
          playsInline
          className="absolute top-0 left-0 w-full h-full object-cover z-0"
        >
          <source src="/video.mp4" type="video/mp4" />
        </video>
        <div className="absolute inset-0 bg-black/50 z-[1]" />
        <div className="max-w-7xl mx-auto text-center relative z-10">
          <h1 className="text-4xl italic sm:text-6xl font-bold mb-6 font-[family-name:var(--font-instrument-serif)]">
            Welcome to Daydream
          </h1>
          <p className="text-lg sm:text-xl mb-8 text-foreground/80 font-[family-name:var(--font-dm-sans)]">
            a journal which can think
          </p>
          <div className="flex flex-col gap-4 items-center">
            <div className="flex flex-col sm:flex-row gap-4">
              <button className="px-6 py-3 rounded-full bg-foreground text-background hover:opacity-90 cursor-pointer font-bold transition-opacity font-[family-name:var(--font-dm-sans)]">
                Download For iOS
              </button>
              <Link
                href="/data"
                className="px-6 py-3 rounded-full border border-foreground/20 hover:bg-foreground/5 cursor-pointer font-bold transition-colors font-[family-name:var(--font-dm-sans)]"
              >
                How we handle your data
              </Link>
            </div>
            <p className="text-sm text-foreground/60 font-[family-name:var(--font-dm-sans)]">
              Android version coming soon
            </p>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 px-4 sm:px-6 lg:px-8 bg-background/95">
        <div className="max-w-7xl mx-auto">
          <h2 className="text-3xl sm:text-4xl font-bold text-center mb-12 font-[family-name:var(--font-instrument-serif)]">
            Why Choose Daydream?
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[
              {
                title: "AI-Powered Insights",
                description:
                  "Get personalized insights and patterns from your journal entries",
                icon: "💭",
              },
              {
                title: "Secure & Private",
                description: "Your thoughts are encrypted and stored securely",
                icon: "🔒",
              },
              {
                title: "Beautiful Interface",
                description:
                  "A clean, intuitive design that makes journaling a pleasure",
                icon: "✨",
              },
            ].map((feature, index) => (
              <div
                key={index}
                className="p-6 rounded-2xl bg-foreground/5 hover:bg-foreground/10 transition-colors"
              >
                <div className="text-4xl mb-4">{feature.icon}</div>
                <h3 className="text-xl font-bold mb-2 font-[family-name:var(--font-instrument-serif)]">
                  {feature.title}
                </h3>
                <p className="text-foreground/70 font-[family-name:var(--font-dm-sans)]">
                  {feature.description}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 px-4 sm:px-6 lg:px-8 bg-foreground text-background">
        <div className="max-w-7xl mx-auto text-center">
          <h2 className="text-3xl sm:text-4xl font-bold mb-6 font-[family-name:var(--font-instrument-serif)]">
            Start Your Journey Today
          </h2>
          <p className="text-lg mb-8 text-background/80 font-[family-name:var(--font-dm-sans)]">
            people who use daydream are cool, i guess
          </p>
          <button className="px-8 py-4 rounded-full bg-background text-foreground hover:opacity-90 cursor-pointer font-bold transition-opacity font-[family-name:var(--font-dm-sans)]">
            Download Now
          </button>
        </div>
      </section>
    </div>
  );
}
