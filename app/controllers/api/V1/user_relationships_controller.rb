# app/controllers/api/v1/user_relationships_controller.rb
module Api
  module V1
    class UserRelationshipsController < BaseController
      before_action :set_current_user
      before_action :set_target_user, only: [:create, :destroy]

      def index
        render json: {
          data: {
            trusted_users: @current_user.trusted_users.as_json(only: [:id, :name, :address]),
            blocked_users: @current_user.blocked_users.as_json(only: [:id, :name, :address]),
            blocked_by_users: User.joins(:blocked_users).where(blocked_users: { id: @current_user.id }).as_json(only: [:id, :name, :address])
          }
        }, status: :ok
      end

      def create
        begin
          unless params[:relationship_type] && params[:target_user_id]
            render json: { data: { message: "Missing parameters", errors: 'missing_parameters' } }, status: :bad_request
            return
          end
        
          unless @current_user
            render json: { data: { message: "Current user not found", errors: 'user_not_found' } }, status: :not_found
            return
          end

          unless @target_user
            render json: { data: { message: "Target user not found", errors: 'user_not_found' } }, status: :not_found
            return
          end
        
          relationship = params[:relationship_type]
          case relationship
          when 'trusted'
            if @current_user.trusted_users.exists?(@target_user.id)
              render json: { data: { message: "User already in the trusted list", errors: 'already_exists' } }, status: :conflict
            else
              @current_user.trusted_users << @target_user
              render json: { data: { message: "User added to trusted list" } }, status: :ok
            end
          when 'blocked'
            if @current_user.blocked_users.exists?(@target_user.id)
              render json: { data: { message: "User already in the blocked list", errors: 'already_exists' } }, status: :conflict
            else
              @current_user.blocked_users << @target_user
              render json: { data: { message: "User added to blocked list" } }, status: :ok
            end
          else
            render json: { data: { message: "Invalid relationship type", errors: 'invalid_type' } }, status: :bad_request
          end
        rescue ActiveRecord::RecordInvalid => e
          render json: { data: { message: e.message, errors: 'record_invalid' } }, status: :unprocessable_entity
        rescue => e
          Rails.logger.error "Error in UserRelationshipsController#create: #{e.message}\n#{e.backtrace.join("\n")}"
          render json: { data: { message: "An unexpected error occurred", errors: 'internal_server_error' } }, status: :internal_server_error
        end
      end

      def destroy
        unless params[:relationship_type] && params[:target_user_id]
          render json: { data: { message: "Missing parameters", errors: 'missing_parameters' } }, status: :bad_request
          return
        end

        relationship = params[:relationship_type]
        case relationship
        when 'trusted'
          if @current_user.trusted_users.exists?(@target_user.id)
            @current_user.trusted_users.delete(@target_user)
            render json: { data: { message: "User removed from trusted list" } }, status: :ok
          else
            render json: { data: { message: "User not found in trusted list", errors: 'not_found' } }, status: :not_found
          end
        when 'blocked'
          if @current_user.blocked_users.exists?(@target_user.id)
            @current_user.blocked_users.delete(@target_user)
            render json: { data: { message: "User removed from blocked list" } }, status: :ok
          else
            render json: { data: { message: "User not found in blocked list", errors: 'not_found' } }, status: :not_found
          end
        else
          render json: { data: { message: "Invalid relationship type", errors: 'invalid_type' } }, status: :bad_request
        end
      end

      private

      def set_current_user
        address = request.headers['X-User-Address']
        @current_user = User.find_by(address: address)
      
        unless @current_user
          render json: { data: { message: 'User not found', errors: 'invalid_token' } }, status: :unauthorized
        end
      end

      def set_target_user
        @target_user = User.where('lower(address) = ?', params[:target_user_id].downcase).first
        unless @target_user
          render json: { data: { message: 'This address is not available in the database.', errors: 'user_not_found' } }, status: :not_found
        end
      rescue Eth::Address::CheckSumError, ArgumentError
        render json: { data: { message: 'Invalid target user address', errors: 'invalid_address' } }, status: :bad_request
      end
      
    end
  end
end