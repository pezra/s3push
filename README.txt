This is some Thor tasks to help use Amazon S3 as a backup for file
that never change.  For example, your music and picture files.  

Usage:
-----

    thor s3_push:push <a-directory> --to-bucket=<bucket-name>", "push all the files in a directory to s3"
    
It will check each file in the specified directory.  If file exists in
the specified S3 bucket it will be skipped.  Otherwise, it is uploaded
to S3.
