class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :sender, class_name: 'User', optional: true

  validates :notification_type, presence: true
  validates :message, presence: true

  # 5分以内に同じ通知がある場合は統合
  def self.create_or_merge_notification(user:, sender:, notification_type:, message:)
    recent_notification = Notification
                            .where(user: user, notification_type: notification_type)
                            .where('created_at > ?', 5.minutes.ago)
                            .first

    if recent_notification && notification_type == 'followed'
      recent_notification.update(message: "#{sender.name} 他#{recent_notification.followers_count + 1}名にフォローされました")
    else
      Notification.create!(user: user, sender: sender, notification_type: notification_type, message: message)
    end
  end
end
