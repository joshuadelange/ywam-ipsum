require 'nokogiri'
require 'uri'
require 'open-uri'

namespace :crawl do

  desc "Crawls all websites!"
  task :all => :environment do

    # for every website
    Website.where(:approved => true).find_each(:batch_size => 1) do |website|

      puts "Website: #{website.url}"

      # add the website front page if wasnt added yet
      website_url = website.url
      unless website_url.include? "http://"
        website_url = "http://#{website_url}"
      end

      unless Page.find_by_url(website_url)

        Page.create!(
          :url => website_url.strip.gsub(" ", "%20"),
          :needs_crawling => true,
          :website_id => website.id
        ).save()

      end

      # for every page that need crawling
      website.page.where(:needs_crawling => true).find_each(:batch_size => 1) do |page|

        puts "Page: #{page.url}"

        begin
          request = open(page.url.strip.gsub("\s", ""))
        rescue => the_error

          puts "Whoops got a bad status code #{the_error.message}"

          # make sure we're not going over this one again later
          page.needs_crawling = false
          page.save()

          next

        end

        # skip images!
        if request.content_type.chomp.include? 'image'
          page.destroy
          next
        end

        doc = Nokogiri::HTML(request)

        # find sub pages on this website!
        doc.css("a").each do |link|

          next if link['href'] == nil

          # i dont want any search results (especially ywam.org ones)
          next if link['href'].include? '/result?'

          # skip ywam.org dynamic contact pages
          next if link['href'].include? '/result-contact-us?email'

          # skip ywam.org comment links
          next if link['href'].include? '#respond'
          next if link['href'].include? '#comments'
          
          # skip uofnkona's #filtering
          next if link['href'].include? '#filter'

          # skip stuff that look like images or uploads
          next if link['href'].include? '/uploads/'
          next if link['href'].include? '.jpg'
          next if link['href'].include? '.jpeg'
          next if link['href'].include? '.png'

          page_url = link['href'].strip

          # lets check if url is relative (and this subpage)
          is_relative = page_url.each_char.first == '/'
          is_subpage = is_relative

          # if not relative, then check if url contains the website url
          unless is_relative
            is_subpage = /^\/|^(https?:\/\/)?#{website.url}/.match(page_url) != nil
          end

          # if subpage, continue!
          if is_subpage

            # if relative, put the website domain in front of it
            if is_relative
              page_url = "#{website.url}#{page_url}"
            end

            # double check for http
            unless page_url.include? 'http'
              page_url = "http://#{page_url}"
            end

            # removing any addtional slashes
            parsed_page_url = URI.parse(page_url)
            parsed_page_url.path.gsub! %r{/+}, '/'

            page_url = parsed_page_url.to_s

            # unless the page already exists...
            unless Page.find_by_url(page_url)

              puts "Added new subpage: #{page_url}"

              Page.create!(
                :url => page_url,
                :needs_crawling => true,
                :website_id => website.id
              ).save()

            end

          end

        end

        # save the words!
        number_of_words_added = 0 ;
        doc.css("h1, h2, h3, h4, h5, h6, a, p, span, li").each do |el|

          # split strings and loop over individual words
          el.content.split(' ').each do |word|

            # meh, too big.
            next if word.bytesize > 255

            # filtering out the bad stuff
            processed_word = word.downcase.strip.gsub(/[^a-z\s]/, '')

            # be sure we're not adding empty strings after all that filtering
            unless processed_word.empty?

              # let the word be created
              Word.create!(
                :word => processed_word,
                :original => word
              ).save()

              # just for keeping track :)
              number_of_words_added += 1

            end

          end

        end

        puts "Added new words: #{number_of_words_added}"

        # make sure we're not going over this one again later
        page.needs_crawling = false
        page.save()

      end

    end

  end

end
