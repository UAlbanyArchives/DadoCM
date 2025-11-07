# Scans page.content for ##, ###, #### headings and builds a nested TOC structure
module Jekyll
  class PageTocGenerator < Generator
    safe true
    priority :low

    def generate(site)
      site.pages.each do |page|
        next unless page.content

        toc = []
        current_h2 = nil

        page.content.each_line do |line|
          if line =~ /^##\s+(.+)$/
            title = clean_title($1)
            anchor = slugify(title)

            # H2: top-level item
            current_h2 = { "title" => title, "anchor" => anchor, "children" => [] }
            toc << current_h2

          elsif line =~ /^###\s+(.+)$/
            next unless current_h2 # skip H3 if no preceding H2
            title = clean_title($1)
            anchor = slugify(title)

            # H3: child of current H2
            current_h2["children"] << { "title" => title, "anchor" => anchor }
          end
        end

        page.data["toc"] = toc
      end
    end

    private

    # Remove Markdown formatting like **bold**, *italic*, `code`, [links](url), etc.
    def clean_title(raw)
      raw.strip
         .gsub(/\\(.)/, '\1') # (unescape backslashes)
         .gsub(/\*\*?/, '') # (remove * and **)
         .gsub(/`/, '') # (remove backticks)
         .gsub(/\[(.*?)\]\(.*?\)/, '\1') # (remove links)
    end

    # Simple slugify for anchor links
    def slugify(title)
      title.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')
    end
  end
end

