/*
Copyright Tonic AI.

Creates a conversations table with a few sample chat transcripts between a customer service agent and a customer.

*/

create table public.conversations
(
    conversation_id int,
    ordering int,
    snippet string
);

insert into conversations (conversation_id, ordering, snippet) values
    (1,1,'agent: Hi, this is ACME customer support.  How can we help you today?'),
    (1,2,'customer: Hi, Im having trouble logging into my account. Its just going to a 404 page.'),
    (1,3,'agent: Ok, that is definitely something I can help with you today. What email address are you using?'),
    (1,4,'customer: sure, its janicesmith@yahoo.com.'),
    (2,1,'agent: Hi, this is ACME customer support.  How are you today?'),
    (2,2,'customer: I\'m fine thanks but y\'all charged my credit card for a subscription i never signed up for.'),
    (2,3,'agent: I\'m sorry to hear that. Let\'s see if we can get this resolve for you now?  Do you have the last 4 digits of your credit card and your billing zip?'),
    (2,4,'customer: sure, its 8475 and the zip is 98103.');