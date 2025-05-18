import fs from "fs";
import path from "path";
import { marked } from "marked";
import Link from "next/link";

export default function DataPage() {
  // Read the markdown file
  const markdownPath = path.join(process.cwd(), "app/data/readmeMd.md");
  const markdownContent = fs.readFileSync(markdownPath, "utf8");
  const htmlContent = marked(markdownContent);

  return (
    <div className="min-h-screen bg-purple-50">
      {/* Banner */}
      <div className="w-full bg-purple-100 border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
          <div className="flex flex-col items-center text-center space-y-6">
            <Link
              href="/"
              className="text-purple-700 hover:text-purple-900 transition-colors font-[family-name:var(--font-dm-sans)] text-sm tracking-wide uppercase"
            >
              ← Back to Home
            </Link>
            <h1 className="text-5xl md:text-6xl font-bold text-purple-900 font-[family-name:var(--font-instrument-serif)] tracking-tight leading-tight">
              How we handle your data
            </h1>
            <p className="text-xl md:text-2xl text-purple-700 max-w-2xl font-[family-name:var(--font-dm-sans)] leading-relaxed">
              Understanding our commitment to data privacy and security
            </p>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
        <div
          className="prose prose-lg prose-purple max-w-none font-[family-name:var(--font-dm-sans)] prose-headings:font-[family-name:var(--font-instrument-serif)] prose-headings:tracking-tight prose-headings:text-purple-900 prose-p:text-purple-700 prose-p:leading-relaxed prose-a:text-purple-600 hover:prose-a:text-purple-700"
          dangerouslySetInnerHTML={{ __html: htmlContent }}
        />
      </div>
    </div>
  );
}
