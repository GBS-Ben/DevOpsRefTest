CREATE TABLE [dbo].[20210913Markful]
(
[id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[createdAt] [datetime2] NULL,
[last_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone_number] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[first_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alt_email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_preference] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_photo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip_code] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company_data_date] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company_parent_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[anniversary_date] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[birthday_month] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[birthday_day] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[team_fb] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[team_bb] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[team_bk] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[team_hk] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alt_seasonal] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[optdown_weekly] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[optdown_monthly] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[role] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[enrollment_date] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lifetime_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order_count] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[average_order_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_order_date] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[average_days_between_orders] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company_parent] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_last_modified] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company_GBSCompanyID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company_parent_GBSCompanyID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[markful_promotions] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company_primary_color] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company_secondary_color] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company_parent_primary_color] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company_parent_secondary_color] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ramp_group] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ramp_number] [int] NULL,
[full_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hom_last_open] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hom_last_click] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[industry] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[source] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sparkpost_valid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sparkpost_result] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sparkpost_delivery_confidence] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sparkpost_reason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sparkpost_is_role] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sparkpost_is_disposable] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sparkpost_is_free] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dynamic] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_order_calendars] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_order_football] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_order_basketball] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_order_nascar] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_order_hockey] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_order_golf] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_order_businesscards] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_order_businesscards_qty] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company_short_code] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_order_baseball] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[channels_email_subscribeStatus] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[channels_email_subinfo_ts] [datetime2] NULL,
[channels_email_unsubinfo_ts] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[channels_email_address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seed_list] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ramp_210709_gmail] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ramp_210709_other] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_210720_hom_other_include] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gmail_ramp] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_210729_Diffs] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[honeypot] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Football_buyers_0803] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_2021_calendar_buyers] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_2021_Football_Buyers] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cal_pads_custom_082621] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cal_pads_stock_082621] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Free100businesscard_purchasers] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_210830_clickers_120day] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email_valid_status] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seed_list2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_063021_OpenCarts] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Buyers_21Football_070221] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ramp_210708] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mrk_ramp_210708] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InProduction_0703_0708] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ramp_210709_gmail2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ramp_210709_other2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Possible_Bots_EXCLUDE] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Buyers_Calendars_2019_2020] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_210714_ramp_gmail] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_210714_ramp_other] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Buyers_Football_071521] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Past_Football_Buyers_2019_2020] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_210716_ramp_other] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_210720_hom_other_include2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_072121_christmasinjuly_Purchasers] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Football_buyers_0726] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REMAXBOC_2021_Attendee_List] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gmail_ramp2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buiness_purchasers_072721] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_210729_Diffs2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[honeypot2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sparkpost_Possible_Bots_EXCLUSION] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Football_buyers_0803_2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REMAX_BOC_NameBadges] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HOM_engagers_210805] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Football_buyers_0811] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Football_buyers_081621] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_2021_calendar_buyers2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_2021_Football_Buyers2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cal_pads_custom_082621_2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cal_pads_stock_082621_2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Free100businesscard_purchasers2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_210830_clickers_120day2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [CI_Email] ON [dbo].[20210913Markful] ([channels_email_address]) ON [PRIMARY]