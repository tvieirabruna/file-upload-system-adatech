import { useState } from "react";
import axios from "axios";
import { ChangeEvent } from "react";
import styles from "../styles/Home.module.css";

const Home = () => {
  const [fileName, setFileName] = useState<string | null>(null);
  const [uploadMessage, setUploadMessage] = useState<boolean>(false);

  const uploadToS3 = async (e: ChangeEvent<HTMLFormElement>) => {
    const formData = new FormData(e.target);
    const file = formData.get("file");

    if (!file) return null;
    // @ts-ignore
    const fileType = encodeURIComponent(file.type);
     // @ts-ignore
    const fileName = encodeURIComponent(file.name);
    const { data } = await axios.get(`/api/media?fileType=${fileType}&fileName=${fileName}`);
    const { uploadUrl } = data;

    await axios.put(uploadUrl, file);
    setFileName(null);
    setUploadMessage(true);
    setTimeout(() => {
      setUploadMessage(false)
    }, 5000);
  };

  const handleSubmit = async (e: ChangeEvent<HTMLFormElement>) => {
    e.preventDefault();
    await uploadToS3(e);
  };

  const handleChangeFileName = (e: ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0].name) {
      const name = e.target.files[0]?.name;
      setFileName(name);
    }
  };

  return (
    <main className={styles.main}>
      <div className={styles.titleContainer}>
        {fileName ? <img src={"/file.svg"} alt="File Icon" width={16} /> : null}
        <h1 className={styles.title}>
          {!fileName ? "Selecione um relatório e faça o upload" : fileName}
        </h1>
      </div>
      <form onSubmit={handleSubmit}>
        <div className={styles.uploadContainer}>
          <div className={styles.labelContainer}>
            <label className={styles.label} htmlFor="contained-button-file">
              <img
                src={fileName ? "/folder-open.svg" : "/folder.svg"}
                alt="Folder Icon"
                width={fileName ? 36 : 32}
                className={styles.folderIcon}
              />
              <p className={styles.labelText}>
                {fileName ? fileName : "Selecionar Relatório"}
              </p>
            </label>
          </div>
          <input
            className={styles.input}
            id="contained-button-file"
            type="file"
            name="file"
            onChange={handleChangeFileName}
          />
          <button
            title="Fazer upload do relatório"
            className={styles.uploadButton}
            type="submit"
            disabled={!fileName}
          >
            Upload
          </button>
        </div>
      </form>
      <h1 className={styles.title}>
          {uploadMessage ? "Upload feito com sucesso!" : ""}
        </h1>
    </main>
  );
};

export default Home;
