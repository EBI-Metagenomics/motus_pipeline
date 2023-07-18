process FETCHTOOL {

    container 'hariszaf/fetch-tool:latest'

    input:
    val reads_accession_number
    val username
    val password

    output:
    tuple val(reads_accession_number), path("download_folder/*/raw/${reads_accession_number}*.fastq.gz"), emit: reads

    script:
    """
    # Make the config file #
    CONF_FILE="fetchdata-config.json"
    echo '{
    "url_max_attempts": 5,
    "ena_api_username": "",
    "ena_api_password": "",
    "aspera_bin": "/app/fetch_tool/aspera-cli/cli/bin/ascp",
    "aspera_cert": "/app/fetch_tool/aspera-cli/cli/etc/asperaweb_id_dsa.openssh"
    }' >> \$CONF_FILE

    fetch-read-tool -d download_folder/ -ru $reads_accession_number -c \$CONF_FILE -v
    """

}
