module Footnotes
  module Notes
    class RoutesNote < AbstractNote
      def initialize(controller)
        @controller = controller
        @parsed_routes = parse_routes
      end

      def legend
        "Routes for #{@controller.class.to_s}"
      end

      def content
        mount_table(@parsed_routes.unshift([:path, :name, :options, :requirements]), :summary => "Debug information for #{title}")
      end

      protected
        def parse_routes
          routes_with_name = Rails.application.routes.named_routes.to_a.flatten

          return Rails.application.routes.filtered_routes(:controller => @controller.controller_path).collect do |route|
            # Catch routes name if exists
            i = routes_with_name.index(route)
            name = i ? routes_with_name[i-1].to_s : ''

            # Catch segments requirements
            req = {}
            if Rails.version < '3.0'
              route.segments.each do |segment|
                next unless segment.is_a?(ActionController::Routing::DynamicSegment) && segment.regexp
                req[segment.key.to_sym] = segment.regexp
              end
              [escape(name), route.segments.join, route.requirements.reject{|key,value| key == :controller}.inspect, req.inspect]
            else
              req = route.conditions
              [escape(name), route.conditions.keys.join, route.requirements.reject{|key,value| key == :controller}.inspect, req.inspect]
            end
          end
        end
    end
  end

  module Extensions
    module Routes
      # Filter routes according to the filter sent
      #
      def filtered_routes(filter = {})
        return [] unless filter.is_a?(Hash)
        return routes.reject do |r|
          route_diff = filter_diff = nil
          
          ActiveSupport::Deprecation.silence do
            filter_diff = filter.diff(r.requirements)
            route_diff  = r.requirements.diff(filter)
          end
          (filter_diff == filter) || (filter_diff != route_diff)
        end
      end
    end
  end
end

if Footnotes::Notes::RoutesNote.included?
  ActionDispatch::Routing::RouteSet.send :include, Footnotes::Extensions::Routes
end
