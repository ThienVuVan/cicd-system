import axios from "axios";
import store from "../store";

export default () => {
  console.log(process.env.VUE_APP_BACKEND_URL);
  return axios.create({
    baseURL: 'https://thienvuvan.shop',
    headers: {
      Authorization: `Bearer ${store.state.CurrentUser.token}`,
    },
  });
};
