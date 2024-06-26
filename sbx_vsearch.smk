# -*- mode: Snakemake -*-

# ---- VSEARCH
TARGET_VSEARCH = [
    expand(str(MAPPING_FP/'vsearch'/'{sample}_report.tsv'), sample = Samples.keys()),
    expand(str(MAPPING_FP/'vsearch'/'{sample}.fasta'), sample = Samples.keys())
    ]

rule all_vsearch:
    input:
        TARGET_VSEARCH

rule fq_2_fa:
    input:
        str(QC_FP / "decontam" / "{sample}_1.fastq.gz"),
    output:
        str(MAPPING_FP / "R1" / "{sample}_1.fasta"),
    benchmark:
        BENCHMARK_FP / "fq_2_fa_{sample}.tsv"
    log:
        LOG_FP / "fq_2_fa_{sample}.log",
    conda:
        "sbx_vsearch_env.yml"
    shell:
        """
        seqtk seq -a < <(gzip -cd {input}) > {output} 2> {log}
        """

rule run_vsearch:
    input:
        query = str(MAPPING_FP/'R1'/'{sample}_1.fasta'),
        db = str(Cfg['sbx_vsearch']['db'])
    output:
        reports = str(MAPPING_FP/'vsearch'/'{sample}_report.tsv'),
        alignments = str(MAPPING_FP/'vsearch'/'{sample}.fasta')
    threads:
        Cfg['sbx_vsearch']['threads']
    params:
        iddef = str(Cfg['sbx_vsearch']['iddef']),
        min_id = str(Cfg['sbx_vsearch']['min_id']),
        userfields = str(Cfg['sbx_vsearch']['userfields']),
        weak_id = str(Cfg['sbx_vsearch']['weak_id']),
        fasta_width = str(Cfg['sbx_vsearch']['fasta_width']),
        maxaccepts = str(Cfg['sbx_vsearch']['maxaccepts'])
    benchmark:
        BENCHMARK_FP / "vsearch_{sample}.tsv"
    log:
        LOG_FP / "vsearch_{sample}.log",
    conda:
        "sbx_vsearch_env.yml"
    shell:
        """
            vsearch --usearch_global {input.query} \
            --db  {input.db} \
            --userout {output.reports} \
            --matched {output.alignments} \
            --threads {threads} \
            --iddef {params.iddef} \
            --id {params.min_id} \
            --userfields {params.userfields} \
            --weak_id {params.weak_id} \
            --fasta_width {params.fasta_width} \
            --maxaccepts {params.maxaccepts}
        """
