CREATE NONCLUSTERED INDEX [IX_RFM] ON [IISLOG] ([COOKIE_ID])
INCLUDE ( [TRANSACTION_VALUE]) ON [PRIMARY]