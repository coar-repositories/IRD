# frozen_string_literal: true
require 'chunky_png'
require 'selenium-webdriver'

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
            options.accept_insecure_certs = true
            options.add_argument('-headless')
            options.add_argument("--width=800")
            options.add_argument("--height=600")
            driver = Selenium::WebDriver.for :firefox, options: options
            Rails.logger.debug "Driver configured for thumbnail generation"
            # driver.manage.timeouts.implicit_wait = 10
            revealed = driver.find_element(tag_name: 'body')
            wait = Selenium::WebDriver::Wait.new
            wait.until { revealed.displayed? }
            driver.manage.timeouts.script_timeout = 5
            driver.manage.timeouts.page_load = 60
            Rails.logger.debug "Navigating to website..."
            driver.navigate.to(system.url)
            Rails.logger.debug "Navigated to website OK"
            if system.thumbnail.attached?
              Rails.logger.debug "Purging existing thumbnail for system: #{system.id}..."
              system.thumbnail.purge
              Rails.logger.debug "Purged thumbnail"
            end
            Rails.logger.debug "Generating screenshot..."
            thumbnail = driver.screenshot_as(:png)
            thumbnail = resize_image(thumbnail)
            Rails.logger.debug "Screenshot generated and resized"
            Rails.logger.debug "Saving thumbnail for system: #{system.id}..."
            system.thumbnail.attach(io: StringIO.new(thumbnail), filename: "#{system.id}.png", content_type: 'image/png')
            Rails.logger.debug "Thumbnail saved"
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