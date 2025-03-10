-- Session 1
-- Question 1
-- Display the content of messages that are often sent by users or users
select
	m."content",
	count(m.message_id) as total_message 
from messages m 
group by 1
order by 2 desc

-- Question 2
-- Display the average message length delivered for each message content
select
	m."content",
	round(avg(length(m.content_messages)), 2) as avg_len_message
from messages m 
group by 1
order by 2 desc

-- Question 3
-- Display information of users who frequently send messages 
select
	u.user_id,
	u.email,
	count(u.user_id) as total_sent_message 
from messages m 
join users u on u.user_id = m.user_id_from 
group by 1
order by 3 desc, 1 asc

-- Question 4
-- Display information of users who frequently receive messages
select
	u.user_id,
	u.email,
	count(u.user_id) as total_receive_message
from messages m 
join users u on u.user_id = m.user_id_to 
group by 1
order by 3 desc, 1 asc

-- Question 5
-- Show whether users who frequently send messages also frequently receive messages or vice versa
with sent_message as(
	select
		u.user_id,
		u.email,
		count(u.user_id) as total_sent_message,
		dense_rank() over(order by count(u.user_id) desc) as rank_sent
	from messages m 
	join users u on u.user_id = m.user_id_from 
	group by 1
),
receive_message as(
	select
		u.user_id,
		u.email,
		count(u.user_id) as total_receive_message,
		dense_rank() over(order by count(u.user_id) desc) as rank_receive
	from messages m 
	join users u on u.user_id = m.user_id_to 
	group by 1
)
select
	sm.user_id, sm.email,
	sm.total_sent_message, sm.rank_sent,
	rm.total_receive_message, rm.rank_receive
from sent_message sm
join receive_message rm on rm.user_id = sm.user_id
order by 4, 1 asc

-- Question 6
-- Show pairs of users who have frequent conversations, 
-- note that sender A and receiver B are the same pair as sender B and receiver A
select 
	least(m.user_id_from, m.user_id_to) as user_id_1,
	greatest(m.user_id_from, m.user_id_to) as user_id_2,
	count(distinct m.message_id) as total_conv 
from messages m 
group by 1,2
order by 3 desc, 1,2 asc
	
-- Question 7
-- Show the total conversations that occurred per hour for each day, and make sure the hour format is (1 - 24) so if 0 is changed to 24
select
	case when extract(hour from(m.created_at)) = 0 then 24 
		else extract(hour from(m.created_at)) end as hour,
	count(m.message_id) as total_message
from messages m 
group by 1
order by 1 asc

-- Question 8
-- Show the country with the most users sending or receiving messages, make sure that 
-- if in the first conversation A is the sender and in another conversation A is the receiver, 
-- then when A is from country X then the total users of country X remains 1 not 2
select 
	u."location",
	count(distinct u.user_id) as total_user 
from messages m 
join users u on u.user_id = m.user_id_from 
	or u.user_id = m.user_id_to
group by 1
order by 2 desc, 1 asc

-- Question 9
-- Show the user's favourite time to send messages with the ‘sticker’ content, and make sure the clock format is (1 - 24) so if 0 is changed to 24
select
	case when extract(hour from(m.created_at)) = 0 then 24 
		else extract(hour from(m.created_at)) end as hour,
	count(m.message_id) as total_message
from messages m 
where m."content" = 'sticker'
group by 1
order by 2 desc

-- Question 10
-- Show a comparison of total users who sent messages with ‘sticker’ content on weekdays and weekends
select
	case 
		when temp.dow in (0,6) then 'Weekend'
		when temp.dow in (1,2,3,4,5) then 'Weekday' end as category,
	avg(total_message) as avg_message
from (
	select
		extract (dow from m.created_at) as dow,
		count(distinct m.message_id) as total_message
	from messages m 
	where m.content = 'sticker'
	group by 1
) as temp
group by 1
order by 2 desc

-- Question 11
-- Display the encrypted message to maintain the confidentiality or privacy of the conversation 
-- by replacing the following characters ‘abcdefghijklmnopqrstuvwxyz’ with ‘0123456789abcdefghijklmnop’
select
	m.message_id,
	length(m.content_messages) as len_msg,
	length(m.content_messages) as len_enc,
	m.content_messages,
	translate(m.content_messages,
		'abcdefghijklmnopqrstuvwxyz',
		'0123456789abcdefghijklmnop') as enc_message
from messages m 
order by 1 asc

-- Question 12
-- Show messages with ‘text’ content that have a message length greater than the average length of messages with that content
select
	m.message_id,
	m."content",
	m.content_messages,
	length(m.content_messages) as length
from messages m 
where m."content" = 'text' and length(m.content_messages) > (
	select round(avg(length(m.content_messages)), 2)
	from messages m
)
order by 1 asc

-- Question 13
-- Show users who have enough conversations per day, whether it's sending messages or receiving messages
with message_sent as(
	select 
		to_char(m.created_at, 'YYYY-MM-DD') as date,
		m.user_id_from as user_id,
		count(m.message_id) as total_sent 
	from messages m 
	group by 1,2
),
message_receive as(
	select 
		to_char(m.created_at, 'YYYY-MM-DD') as date,
		m.user_id_to as user_id,
		count(m.message_id) as total_receive 
	from messages m 
	group by 1,2
)
select
	ms.date, ms.user_id,
	ms.total_sent, mr.total_receive,
	ms.total_sent + mr.total_receive as total_engegament
from message_sent ms
join message_receive mr on ms.user_id = mr.user_id
	and mr.date = ms.date
order by 5 desc, 2 asc

select *
from messages m 
where m.user_id_to = 4
order by m.created_at desc

-- Question 14
-- Show a comparison of the total messages containing the subject ‘I’, ‘you’, or ‘he’ 
-- in messages with the content ‘document’ compared to the total messages in that content
with total_messages as(
	select
		sum(case 
			when content_messages like '%aku%' then (length(content_messages) - length(replace(content_messages, 'aku', ''))) / length('aku')
			when content_messages like '%kamu%' then (length(content_messages) - length(replace(content_messages, 'kamu', ''))) / length('kamu')
			when content_messages like '%dia%' then (length(content_messages) - length(replace(content_messages, 'dia', ''))) / length('dia') end) as total_message,
		count(m.message_id) as total_message_doc 
	from messages m 
	where m."content" = 'document'
)
select *, total_message / total_message_doc::numeric as rate
from total_messages

-- Question 15
-- Show total message senders with the top 3 email domains with the most users on each message content sent
select * from(
select
	m."content",
	split_part(u.email, '@', 2) as domain,
	count(distinct u.user_id) as total_user,
	dense_rank() over(partition by m."content" order by count(distinct u.user_id) desc) as rank_domain
from messages m 
join users u on u.user_id = m.user_id_from 
group by 1,2
)
where rank_domain in (1,2,3)


-- Session 2
-- Question 1
-- Show the content of messages that often get reports, note that the report is a report message, not a user
select 
	m."content",
	count(mr.message_report_id) as total_report 
from messages m 
join messages_reports mr on mr.message_id = m.message_id 
group by 1
order by 2 desc

-- Question 2
-- Show users who often get reports in total from report messages or user reports
select
	m.user_id_from as user_id,
	count(distinct mr.message_report_id) as from_message,
	count(distinct ur.user_report_id) as from_user,
	count(distinct mr.message_report_id) + count(distinct ur.user_report_id) as total_report
from messages m 
join users u on u.user_id = m.user_id_from 
left join messages_reports mr on mr.message_id = m.message_id 
left join users_reports ur on ur.message_id = m.message_id 
group by 1
order by 4 desc, 1 asc

-- Question 3
-- Show users who never get reports from message reports and user reports
select distinct 
	u.user_id,
	u.email,
	u."location"
from messages m 
join users u on u.user_id = m.user_id_from 
left join messages_reports mr on mr.message_id = m.message_id 
left join users_reports ur on ur.message_id = m.message_id 
where u.user_id not in (
	select u.user_id 
	from messages m 
	join users u on u.user_id = m.user_id_from 
	left join messages_reports mr on mr.message_id = m.message_id 
	left join users_reports ur on ur.message_id = m.message_id
	where mr.message_report_id is not null or ur.user_report_id is not null)
order by 1 asc

-- Question 4
-- Show countries with total users who frequently get user reports and report messages
select
	u."location",
	count(mr.message_report_id) + count(ur.user_report_id) as total_report 
from messages m 
join users u on u.user_id = m.user_id_from 
left join messages_reports mr on mr.message_id = m.message_id 
left join users_reports ur on ur.message_id = m.message_id 
group by 1
order by 2 desc

-- Question 5
-- Show the most frequent time a user or a message gets a report
with report_message as(
	select
		case when extract(hour from(mr.created_at)) = 0 then 24 
			else extract(hour from(mr.created_at)) end as hour,
		count(mr.message_report_id) as from_message
	from messages_reports mr 
	group by 1
),
report_user as(
	select
		case when extract(hour from(ur.created_at)) = 0 then 24 
			else extract(hour from(ur.created_at)) end as hour,
		count(ur.user_report_id) as from_user
	from users_reports ur 
	group by 1
)
select
	rm.hour,
	rm.from_message,
	ru.from_user,
	rm.from_message + ru.from_user as total_report
from report_message rm
join report_user ru on ru.hour = rm.hour
order by 4 desc

-- Question 6
-- Show days with the total messages that got the report
with report_message as(
	select
		case when extract(dow from mr.created_at) = 0 then 'Sunday' 
			when extract(dow from mr.created_at) = 1 then 'Monday'
			when extract(dow from mr.created_at) = 2 then 'Tuesday'
			when extract(dow from mr.created_at) = 3 then 'Wednesday'
			when extract(dow from mr.created_at) = 4 then 'Thrusday'
			when extract(dow from mr.created_at) = 5 then 'Friday'
			else 'Saturday' end as day_of_week,
		count(mr.message_report_id) as from_message
	from messages_reports mr 
	group by 1
),
report_user as(
	select
		case when extract(dow from ur.created_at) = 0 then 'Sunday' 
			when extract(dow from ur.created_at) = 1 then 'Monday'
			when extract(dow from ur.created_at) = 2 then 'Tuesday'
			when extract(dow from ur.created_at) = 3 then 'Wednesday'
			when extract(dow from ur.created_at) = 4 then 'Thrusday'
			when extract(dow from ur.created_at) = 5 then 'Friday'
			else 'Saturday' end as day_of_week,
		count(ur.user_report_id) as from_user
	from users_reports ur 
	group by 1
)
select
	rm.day_of_week,
	rm.from_message,
	ru.from_user,
	rm.from_message + ru.from_user as total_report
from report_message rm
join report_user ru on ru.day_of_week = rm.day_of_week
order by 4 desc

-- Question 7
-- Show users who get reports more than once (report user not message)
select * from(
	select
		m.user_id_from as user_id,
		m.message_id,
		ur.reason_text,
		ur.created_at,
		count(m.user_id_from) over(partition by m.user_id_from)
	from messages m 
	join users_reports ur on ur.message_id = m.message_id 
	group by 1,2,3,4
) as temp_table
where count > 1

-- Question 8
-- Show the average message length of a message that gets a report for each report category label
select
	rr.report_reason_label,
	count(rr.report_reason_id) as total_report,
	count(distinct m.user_id_from) as total_user,
	round(avg(length(m.content_messages)), 2) as avg_len_message
from messages m 
join messages_reports mr on mr.message_id = m.message_id 
join report_reasons rr on rr.report_reason_id = mr.reason_id 
group by 1
order by 2 desc

-- Question 9
-- Show users' email domains that get reports most often and get top 5
select
	split_part(u.email, '@', 2) as domain,
	count(mr.message_report_id) as cnt_report 
from users u 
join messages m on m.user_id_from = u.user_id 
join messages_reports mr on mr.message_id = m.message_id 
group by 1
order by 2 desc
limit 5

-- Question 10
-- Show the percentage report for each country, by comparing the total users who got the report in a country compared to the total users of that country
select
	u."location",
	count(distinct mr.message_report_id) as count_report_msg,
	count(m.message_id) as count_total_msg,
	count(distinct mr.message_report_id) / count(m.message_id)::numeric * 100 as percent_report
from messages m 
join users u on u.user_id = m.user_id_from 
left join messages_reports mr on mr.message_id = m.message_id 
group by 1

-- Question 11
-- Show the most popular content submitted by users per day
select * from(
	select 
		to_char(m.created_at, 'YYYY-MM-DD') get_date,
		m."content",
		count(m.message_id) as qty_content,
		row_number() over(partition by to_char(m.created_at, 'YYYY-MM-DD') order by count(m.message_id) desc) as rank_content
	from messages m 
	group by 1,2
) as temp 
where rank_content = 1

-- Question 12
-- Show users who send less than 5 messages and get message reports
select * from(
	select 
		m.user_id_from,
		u.email,
		u."location",
		count(m.message_id) over(partition by m.user_id_from) as cnt_send_msg,
		rr.report_reason_label
	from messages m 
	join users u on u.user_id = m.user_id_from 
	left join messages_reports mr on mr.message_id = m.message_id 
	left join report_reasons rr on rr.report_reason_id = mr.reason_id
	group by 1,2,3,m.message_id, 5
) as temp_table
where cnt_send_msg <= 5 and report_reason_label is not null
order by 4 desc

-- Question 13
-- Show the most frequent content in the report message and its users
with report_message as(
	select
		m."content",
		count(mr.message_report_id) as qty_report_message 
	from messages m 
	join messages_reports mr on mr.message_id = m.message_id 
	group by 1
),
report_user as(
	select 
		m."content",
		count(ur.user_report_id) as qty_user_message 
	from messages m 
	join users_reports ur on ur.message_id = m.message_id 
	group by 1
)
select
	rm."content",
	rm.qty_report_message,
	ru.qty_user_message
from report_message rm
join report_user ru on ru."content" = rm."content"
order by 2 desc

-- Question 14
-- Show the most active month and date in each region for sending messages
-- If each period has the same number of messages, return both data
select 
	to_char(m.created_at, 'YYYY-MM') as period_chat,
	u."location",
	m."content",
	count(m.message_id) as cnt_msg 
from messages m 
join users u on u.user_id = m.user_id_from 
group by 1,2,3

-- Question 15
-- Show the growth of the number of messages from day to day
select * from(
	select 
		to_char(m.created_at, 'YYYY-MM-DD') as created_at,
		count(m.message_id) as curr_cnt_msg,
		lag(count(m.message_id)) over() as prev_cnt_msg,
		round(((count(m.message_id) - lag(count(m.message_id)) over()) * 100
			/ count(m.message_id)::numeric), 2) as growth_percentage
	from messages m 
	group by 1
	order by 1 asc
) as a
where prev_cnt_msg is not null