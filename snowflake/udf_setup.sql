/*
Copyright Tonic AI.

Creates a UDF which wraps the Tonic Textual API for free text redaction

*/

CREATE OR REPLACE SECRET TEXTUAL_API_KEY
    TYPE = GENERIC_STRING
    SECRET_STRING = '<Textual API Key>';


CREATE OR REPLACE SECRET TEXTUAL_BASE_URL
    TYPE = GENERIC_STRING
    SECRET_STRING = 'https://textual.tonic.ai';


USE ROLE SYSADMIN;
CREATE OR REPLACE NETWORK RULE textual_egress_rule
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('https://textual.tonic.ai');

USE ROLE ACCOUNTADMIN;
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION textual
  ALLOWED_NETWORK_RULES = (textual_egress_rule)
  ALLOWED_AUTHENTICATION_SECRETS = (TEXTUAL_API_KEY, TEXTUAL_BASE_URL)
  ENABLED = TRUE;
  
CREATE OR REPLACE FUNCTION udf_redact(x string)
returns string
language python
runtime_version = 3.8
packages = ('pandas', 'requests')
handler = 'redact_string'
EXTERNAL_ACCESS_INTEGRATIONS = (textual)
SECRETS = ('textual_api_key' = TEXTUAL_API_KEY, 'textual_base_url' = TEXTUAL_BASE_URL )
as $$
import pandas
import requests
import _snowflake

from _snowflake import vectorized

def redact_api_call(text):
  api_key = _snowflake.get_generic_secret_string('textual_api_key')
  base_url = _snowflake.get_generic_secret_string('textual_base_url')
  headers = {"Authorization": api_key, "User-Agent": "tonic-textual-snowflake-udf"}  
  data = {"Text": text}
  res = requests.post(base_url + '/api/redact', json=data, headers=headers, verify=False)  
  res.raise_for_status()
  return res.json()

@vectorized(input=pandas.DataFrame, max_batch_size=100)
def redact_string(df):
  def t(x):
    r = redact_api_call(x)
    return r['redactedText']
  return df[0].apply(lambda x: t(x))
$$;