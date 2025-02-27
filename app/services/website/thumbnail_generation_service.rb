# frozen_string_literal: true
require "chunky_png"
require "selenium-webdriver"

module Website
  class ThumbnailGenerationService < ApplicationService

    def call(system_id,refresh_thumbnail)
      begin
        system = System.includes(:network_checks,:repoids,:media,:annotations,:users).find(system_id)
        driver = nil
        unless !system || system.url.blank?
          if (system.thumbnail.attached? == false) || refresh_thumbnail
            Rails.logger.debug "Starting thumbnail generation for system: #{system.id}..."
            system.thumbnail.purge if system.thumbnail.attached?
            options = Selenium::WebDriver::Options.firefox
            options.page_load_strategy = :normal
            options.accept_insecure_certs = true
            options.unhandled_prompt_behavior = :accept
            # options.timeouts = {script: 30_000, page_load: 300_00}
            # options.set_window_rect = true
            options.strict_file_interactability = false
            options.add_argument("-headless")
            options.add_argument("--width=800")
            options.add_argument("--height=600")
            driver = Selenium::WebDriver.for :firefox, options: options
            Rails.logger.debug "Driver configured for thumbnail generation"
            Rails.logger.debug "Navigating to website..."
            driver.navigate.to(system.url)
            # sleep(10.seconds)
            sleep(ENV.fetch("THUMBNAIL_GENERATOR_WAIT_SECONDS", 10).to_i)
            revealed = driver.find_element(tag_name: "body")
            wait = Selenium::WebDriver::Wait.new
            wait.until { revealed.displayed? }
            Rails.logger.debug "Navigated to website OK"
            Rails.logger.debug "Generating screenshot..."
            new_thumbnail = driver.screenshot_as(:png)
            new_thumbnail = resize_image(new_thumbnail)
            if new_thumbnail
              Rails.logger.debug "Screenshot generated and resized"
              if system.thumbnail.attached?
                Rails.logger.debug "Purging existing thumbnail for system: #{system.id}..."
                system.thumbnail.purge
                Rails.logger.debug "Purged thumbnail"
              end
              Rails.logger.debug "Saving thumbnail for system: #{system.id}..."
              system.thumbnail.attach(io: StringIO.new(new_thumbnail), filename: "#{system.id}.png", content_type: "image/png")
              Rails.logger.debug "Thumbnail saved"
            end
          end
        end
        success true
      rescue StandardError => e
        Rails.logger.error "WebsiteThumbnailJob for system: #{system.id}: #{e.message}"
        failure e
      ensure
        begin
          driver.quit if driver
        rescue StandardError => e2
          Rails.logger.warn "WebsiteThumbnailJob for system (error closing driver): #{system.id}: #{e2.message}"
        end
      end
    end

    private

    def resize_image(screenshot)
      img = ChunkyPNG::Image.from_blob(screenshot)
      img = img.resize((img.width * 0.5).floor, (img.height * 0.5).floor)
      img.to_blob
    end

  end

end